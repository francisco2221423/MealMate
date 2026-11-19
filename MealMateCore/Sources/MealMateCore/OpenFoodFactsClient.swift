import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct OpenFoodFactsClient: Sendable {
    private let session: URLSession
    // A API pede um User-Agent identificável: troca pelo teu email.
    private let userAgent = "MealMate/1.0 (o-teu-email@exemplo.pt)"

    public init(session: URLSession = .shared) { self.session = session }

    public func search(_ query: String, pageSize: Int = 20) async throws -> [FoodItem] {
        var c = URLComponents(string: "https://world.openfoodfacts.org/cgi/search.pl")!
        c.queryItems = [
            .init(name: "search_terms", value: query),
            .init(name: "search_simple", value: "1"),
            .init(name: "action", value: "process"),
            .init(name: "json", value: "1"),
            .init(name: "page_size", value: String(pageSize)),
            .init(name: "fields", value: "code,product_name,brands,nutriments,image_url"),
        ]
        let data = try await fetch(c.url!)
        return try JSONDecoder().decode(SearchResponse.self, from: data)
            .products.compactMap { $0.toFoodItem() }
    }

    public func product(barcode: String) async throws -> FoodItem? {
        let url = URL(string: "https://world.openfoodfacts.org/api/v2/product/\(barcode).json")!
        let data = try await fetch(url)
        return try JSONDecoder().decode(ProductResponse.self, from: data).product?.toFoodItem()
    }

    private func fetch(_ url: URL) async throws -> Data {
        var req = URLRequest(url: url)
        req.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        let (data, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return data
    }
}

private struct SearchResponse: Decodable { let products: [ProductDTO] }
private struct ProductResponse: Decodable { let product: ProductDTO? }

private struct ProductDTO: Decodable {
    let code: String?
    let product_name: String?
    let brands: String?
    let image_url: String?
    let nutriments: [String: FlexibleDouble]?

    func toFoodItem() -> FoodItem? {
        guard let code, let name = product_name, !name.isEmpty else { return nil }
        var nutrition: Nutrition?
        if let n = nutriments, let kcal = n["energy-kcal_100g"]?.value {
            nutrition = Nutrition(kcal: kcal,
                                  protein: n["proteins_100g"]?.value ?? 0,
                                  carbs: n["carbohydrates_100g"]?.value ?? 0,
                                  fat: n["fat_100g"]?.value ?? 0)
        }
        return FoodItem(id: code, name: name, brand: brands,
                        per100g: nutrition, imageURL: image_url.flatMap(URL.init))
    }
}

private struct FlexibleDouble: Decodable {
    let value: Double?
    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let d = try? c.decode(Double.self) { value = d }
        else if let s = try? c.decode(String.self) { value = Double(s) }
        else { value = nil }
    }
}
