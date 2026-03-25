import Foundation

struct Citation: Identifiable, Codable, Equatable {
    let id: UUID
    let sourceURL: String
    let sourceTitle: String
    let extractedText: String
    let pageSection: String?
    let relevantQuote: String?

    init(
        id: UUID = UUID(),
        sourceURL: String,
        sourceTitle: String = "",
        extractedText: String = "",
        pageSection: String? = nil,
        relevantQuote: String? = nil
    ) {
        self.id = id
        self.sourceURL = sourceURL
        self.sourceTitle = sourceTitle
        self.extractedText = extractedText
        self.pageSection = pageSection
        self.relevantQuote = relevantQuote
    }

    var displayTitle: String {
        if !sourceTitle.isEmpty { return sourceTitle }
        guard let url = URL(string: sourceURL) else { return sourceURL }
        return url.host ?? sourceURL
    }

    var shortDomain: String {
        guard let url = URL(string: sourceURL) else { return "source" }
        return url.host?.replacingOccurrences(of: "www.", with: "") ?? "source"
    }
}
