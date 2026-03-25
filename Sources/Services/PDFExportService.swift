import Foundation
import PDFKit
#if canImport(UIKit)
import UIKit
#endif

/// R4: Export synthesis as PDF (iOS only)
#if canImport(UIKit)
final class PDFExportService: @unchecked Sendable {
    static let shared = PDFExportService()

    private init() {}

    func generateSynthesisPDF(session: GrappleSession) -> Data? {
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 72

        let pdfMetaData = [
            kCGPDFContextCreator: "Grapple",
            kCGPDFContextAuthor: "Grapple App",
            kCGPDFContextTitle: "Grapple Synthesis: \(session.topic)"
        ]

        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let data = renderer.pdfData { context in
            context.beginPage()
            var yPosition: CGFloat = margin

            let titleFont = UIFont.systemFont(ofSize: 24, weight: .bold)
            let headingFont = UIFont.systemFont(ofSize: 14, weight: .semibold)
            let bodyFont = UIFont.systemFont(ofSize: 11, weight: .regular)
            let captionFont = UIFont.systemFont(ofSize: 9, weight: .regular)

            let textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
            let accentColor = UIColor(red: 0.29, green: 0.56, blue: 0.85, alpha: 1.0)
            let mutedColor = UIColor(red: 0.55, green: 0.61, blue: 0.71, alpha: 1.0)

            let titleText = "Grapple Synthesis"
            let titleAttrs: [NSAttributedString.Key: Any] = [.font: titleFont, .foregroundColor: accentColor]
            _ = CGRect(x: margin, y: yPosition, width: pageWidth - 2 * margin, height: 36)
            titleText.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: titleAttrs)
            yPosition += 42

            let topicText = "Topic: \(session.topic)"
            topicText.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: [.font: headingFont, .foregroundColor: textColor])
            yPosition += 28

            let metaText = "\(session.debateMode.rawValue) · \(session.createdAt.formatted(date: .long, time: .omitted))"
            metaText.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: [.font: captionFont, .foregroundColor: mutedColor])
            yPosition += 24

            let dividerPath = UIBezierPath()
            dividerPath.move(to: CGPoint(x: margin, y: yPosition))
            dividerPath.addLine(to: CGPoint(x: pageWidth - margin, y: yPosition))
            dividerPath.lineWidth = 0.5
            accentColor.withAlphaComponent(0.3).setStroke()
            dividerPath.stroke()
            yPosition += 20

            if !session.originalInput.isEmpty {
                "Your Original Thought".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: [.font: headingFont, .foregroundColor: textColor])
                yPosition += 20
                session.originalInput.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: [.font: bodyFont, .foregroundColor: mutedColor])
                yPosition += 68
            }

            if let synth = session.synthesis {
                "Final Verdict".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: [.font: headingFont, .foregroundColor: textColor])
                yPosition += 20
                synth.verdict.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: [.font: UIFont.italicSystemFont(ofSize: 13), .foregroundColor: textColor])
                yPosition += 38

                let sections: [(String, String, UIColor)] = [
                    ("What Survived", synth.whatSurvived, UIColor(red: 0.32, green: 0.72, blue: 0.53, alpha: 1.0)),
                    ("What Collapsed", synth.whatCollapsed, UIColor(red: 0.90, green: 0.22, blue: 0.27, alpha: 1.0)),
                    ("Needs Evidence", synth.needsEvidence, UIColor(red: 0.96, green: 0.64, blue: 0.38, alpha: 1.0))
                ]
                for (title, content, color) in sections {
                    if yPosition > pageHeight - 120 { context.beginPage(); yPosition = margin }
                    title.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: [.font: headingFont, .foregroundColor: color])
                    yPosition += 22
                    content.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: [.font: bodyFont, .foregroundColor: textColor])
                    yPosition += 88
                }

                yPosition += 10
                let s = session.rebuttals.filter { $0.judgment == .strong }.count
                let p = session.rebuttals.filter { $0.judgment == .partial }.count
                let w = session.rebuttals.filter { $0.judgment == .weak }.count
                "Rebuttal Summary: \(s) Strong · \(p) Partial · \(w) Weak".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: [.font: captionFont, .foregroundColor: mutedColor])
            }
        }
        return data
    }

    func saveSynthesisPDF(session: GrappleSession) -> URL? {
        guard let pdfData = generateSynthesisPDF(session: session) else { return nil }
        let fileName = "Grapple_\(session.topic.prefix(30).replacingOccurrences(of: " ", with: "_")).pdf"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        do {
            try pdfData.write(to: tempURL)
            return tempURL
        } catch {
            print("Failed to save PDF: \(error)")
            return nil
        }
    }
}
#else
// macOS stub
final class PDFExportService: @unchecked Sendable {
    static let shared = PDFExportService()
    private init() {}
    func generateSynthesisPDF(session: GrappleSession) -> Data? { nil }
    func saveSynthesisPDF(session: GrappleSession) -> URL? { nil }
}
#endif
