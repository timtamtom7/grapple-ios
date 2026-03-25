import Foundation
import UIKit
import PDFKit

/// R4: Export synthesis as PDF
final class PDFExportService: @unchecked Sendable {
    static let shared = PDFExportService()

    private init() {}

    /// Generate a PDF document from a GrappleSession's synthesis
    func generateSynthesisPDF(session: GrappleSession) -> Data? {
        let pageWidth: CGFloat = 612  // US Letter
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 72     // 1 inch margins

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

            // Title
            let titleText = "Grapple Synthesis"
            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .foregroundColor: accentColor
            ]
            let titleRect = CGRect(x: margin, y: yPosition, width: pageWidth - 2 * margin, height: 36)
            titleText.draw(in: titleRect, withAttributes: titleAttrs)
            yPosition += 42

            // Topic
            let topicText = "Topic: \(session.topic)"
            let topicAttrs: [NSAttributedString.Key: Any] = [
                .font: headingFont,
                .foregroundColor: textColor
            ]
            let topicRect = CGRect(x: margin, y: yPosition, width: pageWidth - 2 * margin, height: 20)
            topicText.draw(in: topicRect, withAttributes: topicAttrs)
            yPosition += 28

            // Mode and date
            let metaText = "\(session.debateMode.rawValue) · \(session.createdAt.formatted(date: .long, time: .omitted))"
            let metaAttrs: [NSAttributedString.Key: Any] = [
                .font: captionFont,
                .foregroundColor: mutedColor
            ]
            let metaRect = CGRect(x: margin, y: yPosition, width: pageWidth - 2 * margin, height: 14)
            metaText.draw(in: metaRect, withAttributes: metaAttrs)
            yPosition += 24

            // Divider
            let dividerPath = UIBezierPath()
            dividerPath.move(to: CGPoint(x: margin, y: yPosition))
            dividerPath.addLine(to: CGPoint(x: pageWidth - margin, y: yPosition))
            dividerPath.lineWidth = 0.5
            accentColor.withAlphaComponent(0.3).setStroke()
            dividerPath.stroke()
            yPosition += 20

            // Original thought
            if !session.originalInput.isEmpty {
                let originalLabel = "Your Original Thought"
                let labelAttrs: [NSAttributedString.Key: Any] = [
                    .font: headingFont,
                    .foregroundColor: textColor
                ]
                originalLabel.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: labelAttrs)
                yPosition += 20

                let originalAttrs: [NSAttributedString.Key: Any] = [
                    .font: bodyFont,
                    .foregroundColor: mutedColor
                ]
                let originalRect = CGRect(x: margin, y: yPosition, width: pageWidth - 2 * margin, height: 60)
                session.originalInput.draw(in: originalRect, withAttributes: originalAttrs)
                yPosition += 68
            }

            // Synthesis
            if let synth = session.synthesis {
                let sectionAttrs: [NSAttributedString.Key: Any] = [
                    .font: headingFont,
                    .foregroundColor: textColor
                ]

                // Verdict
                let verdictLabel = "Final Verdict"
                verdictLabel.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: sectionAttrs)
                yPosition += 20

                let verdictAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.italicSystemFont(ofSize: 13),
                    .foregroundColor: textColor
                ]
                let verdictRect = CGRect(x: margin, y: yPosition, width: pageWidth - 2 * margin, height: 30)
                synth.verdict.draw(in: verdictRect, withAttributes: verdictAttrs)
                yPosition += 38

                // Sections
                let sections = [
                    ("What Survived", synth.whatSurvived, UIColor(red: 0.32, green: 0.72, blue: 0.53, alpha: 1.0)),
                    ("What Collapsed", synth.whatCollapsed, UIColor(red: 0.90, green: 0.22, blue: 0.27, alpha: 1.0)),
                    ("Needs Evidence", synth.needsEvidence, UIColor(red: 0.96, green: 0.64, blue: 0.38, alpha: 1.0))
                ]

                for (title, content, color) in sections {
                    // Check page break
                    if yPosition > pageHeight - 120 {
                        context.beginPage()
                        yPosition = margin
                    }

                    // Section title
                    let sectionAttrs: [NSAttributedString.Key: Any] = [
                        .font: headingFont,
                        .foregroundColor: color
                    ]
                    title.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: sectionAttrs)
                    yPosition += 22

                    // Content
                    let contentAttrs: [NSAttributedString.Key: Any] = [
                        .font: bodyFont,
                        .foregroundColor: textColor
                    ]
                    let contentRect = CGRect(x: margin, y: yPosition, width: pageWidth - 2 * margin, height: 80)
                    content.draw(in: contentRect, withAttributes: contentAttrs)
                    yPosition += 88
                }

                // Stats
                if yPosition > pageHeight - 80 {
                    context.beginPage()
                    yPosition = margin
                }

                yPosition += 10
                let strongCount = session.rebuttals.filter { $0.judgment == .strong }.count
                let partialCount = session.rebuttals.filter { $0.judgment == .partial }.count
                let weakCount = session.rebuttals.filter { $0.judgment == .weak }.count

                let statsText = "Rebuttal Summary: \(strongCount) Strong · \(partialCount) Partial · \(weakCount) Weak"
                let statsAttrs: [NSAttributedString.Key: Any] = [
                    .font: captionFont,
                    .foregroundColor: mutedColor
                ]
                statsText.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: statsAttrs)
                yPosition += 18
            }

            // Footer
            yPosition = pageHeight - margin
            let footerText = "Generated by Grapple · \(Date().formatted(date: .abbreviated, time: .shortened))"
            let footerAttrs: [NSAttributedString.Key: Any] = [
                .font: captionFont,
                .foregroundColor: mutedColor
            ]
            let footerRect = CGRect(x: margin, y: yPosition, width: pageWidth - 2 * margin, height: 14)
            footerText.draw(in: footerRect, withAttributes: footerAttrs)
        }

        return data
    }

    /// Save PDF to temp file and return URL
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
