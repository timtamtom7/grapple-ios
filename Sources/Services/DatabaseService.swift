import Foundation
import SQLite

@MainActor
final class DatabaseService: ObservableObject {
    static let shared = DatabaseService()

    private var db: Connection?

    // Tables
    private let sessions = Table("sessions")
    private let counterArguments = Table("counter_arguments")
    private let rebuttals = Table("rebuttals")
    private let synthesisTable = Table("synthesis")

    // Session columns
    private let id = SQLite.Expression<String>("id")
    private let topic = SQLite.Expression<String>("topic")
    private let originalInput = SQLite.Expression<String>("original_input")
    private let outcome = SQLite.Expression<String>("outcome")
    private let createdAt = SQLite.Expression<Double>("created_at")
    private let debateModeCol = SQLite.Expression<String>("debate_mode")
    private let sourceURLsCol = SQLite.Expression<String>("source_urls")

    // Counter argument columns
    private let sessionId = SQLite.Expression<String>("session_id")
    private let argType = SQLite.Expression<String>("type")
    private let argText = SQLite.Expression<String>("text")
    private let severity = SQLite.Expression<Int>("severity")
    private let confidenceScoreCol = SQLite.Expression<Double>("confidence_score")
    private let sourceAttrCol = SQLite.Expression<String?>("source_attribution")

    // Rebuttal columns
    private let argumentId = SQLite.Expression<String>("argument_id")
    private let rebuttalText = SQLite.Expression<String>("text")
    private let judgment = SQLite.Expression<String>("judgment")
    private let confidenceLevelCol = SQLite.Expression<String>("confidence_level")

    // Synthesis columns
    private let whatSurvived = SQLite.Expression<String>("what_survived")
    private let whatCollapsed = SQLite.Expression<String>("what_collapsed")
    private let needsEvidence = SQLite.Expression<String>("needs_evidence")
    private let verdict = SQLite.Expression<String>("verdict")
    private let factChecksCol = SQLite.Expression<String>("fact_checks")
    private let overallConfidenceCol = SQLite.Expression<String>("overall_confidence")

    @Published var sessionsList: [GrappleSession] = []

    private init() {
        setupDatabase()
        loadSessions()
    }

    private func setupDatabase() {
        do {
            let documentsPath: String
            if let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
                documentsPath = path
            } else if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                documentsPath = url.path
            } else {
                documentsPath = NSTemporaryDirectory()
            }
            db = try Connection("\(documentsPath)/grapple.sqlite3")
            try createTables()
        } catch {
            print("Database setup error: \(error)")
        }
    }

    private func createTables() throws {
        guard let db = db else { return }

        try db.run(sessions.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(topic)
            t.column(originalInput)
            t.column(outcome)
            t.column(createdAt)
            t.column(debateModeCol)
            t.column(sourceURLsCol)
        })

        try db.run(counterArguments.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(sessionId)
            t.column(argType)
            t.column(argText)
            t.column(severity)
            t.column(confidenceScoreCol)
            t.column(sourceAttrCol)
        })

        try db.run(rebuttals.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(argumentId)
            t.column(rebuttalText)
            t.column(judgment)
            t.column(confidenceLevelCol)
        })

        try db.run(synthesisTable.create(ifNotExists: true) { t in
            t.column(sessionId, primaryKey: true)
            t.column(whatSurvived)
            t.column(whatCollapsed)
            t.column(needsEvidence)
            t.column(verdict)
            t.column(factChecksCol)
            t.column(overallConfidenceCol)
        })
    }

    func saveSession(_ session: GrappleSession) {
        guard let db = db else { return }

        do {
            let sourceURLsJson = (try? String(data: JSONEncoder().encode(session.sourceURLs), encoding: .utf8)) ?? "[]"

            let insert = sessions.insert(or: .replace,
                id <- session.id.uuidString,
                topic <- session.topic,
                originalInput <- session.originalInput,
                outcome <- session.outcome.rawValue,
                createdAt <- session.createdAt.timeIntervalSince1970,
                debateModeCol <- session.debateMode.rawValue,
                sourceURLsCol <- sourceURLsJson
            )
            try db.run(insert)

            for arg in session.counterArguments {
                let argInsert = counterArguments.insert(or: .replace,
                    id <- arg.id.uuidString,
                    sessionId <- session.id.uuidString,
                    argType <- arg.type.rawValue,
                    argText <- arg.text,
                    severity <- arg.severity,
                    confidenceScoreCol <- arg.confidenceScore,
                    sourceAttrCol <- arg.sourceAttribution
                )
                try db.run(argInsert)
            }

            for rebuttal in session.rebuttals {
                let rebuttalInsert = rebuttals.insert(or: .replace,
                    id <- rebuttal.id.uuidString,
                    argumentId <- rebuttal.argumentId.uuidString,
                    rebuttalText <- rebuttal.text,
                    judgment <- rebuttal.judgment.rawValue,
                    confidenceLevelCol <- rebuttal.confidenceLevel.rawValue
                )
                try db.run(rebuttalInsert)
            }

            if let synth = session.synthesis {
                let factChecksJson = (try? String(data: JSONEncoder().encode(synth.factChecks), encoding: .utf8)) ?? "[]"
                let synthInsert = synthesisTable.insert(or: .replace,
                    sessionId <- session.id.uuidString,
                    whatSurvived <- synth.whatSurvived,
                    whatCollapsed <- synth.whatCollapsed,
                    needsEvidence <- synth.needsEvidence,
                    verdict <- synth.verdict,
                    factChecksCol <- factChecksJson,
                    overallConfidenceCol <- synth.overallConfidence.rawValue
                )
                try db.run(synthInsert)
            }

            loadSessions()
        } catch {
            print("Save session error: \(error)")
        }
    }

    func deleteSession(_ session: GrappleSession) {
        guard let db = db else { return }

        do {
            let sessionQuery = sessions.filter(id == session.id.uuidString)
            try db.run(sessionQuery.delete())

            let argsQuery = counterArguments.filter(sessionId == session.id.uuidString)
            try db.run(argsQuery.delete())

            for arg in session.counterArguments {
                let rebuttalsQuery = rebuttals.filter(argumentId == arg.id.uuidString)
                try db.run(rebuttalsQuery.delete())
            }

            let synthQuery = synthesisTable.filter(sessionId == session.id.uuidString)
            try db.run(synthQuery.delete())

            loadSessions()
        } catch {
            print("Delete session error: \(error)")
        }
    }

    func loadSessions() {
        guard let db = db else { return }

        var loadedSessions: [GrappleSession] = []

        do {
            for row in try db.prepare(sessions.order(createdAt.desc)) {
                let sessionUUID = UUID(uuidString: row[id]) ?? UUID()
                let outcomeVal = SessionOutcome(rawValue: row[outcome]) ?? .mixed
                let dmVal = DebateMode(rawValue: row[debateModeCol]) ?? .standard

                var sourceURLs: [String] = []
                if let data = row[sourceURLsCol].data(using: .utf8) {
                    sourceURLs = (try? JSONDecoder().decode([String].self, from: data)) ?? []
                }

                var args: [CounterArgument] = []
                for argRow in try db.prepare(counterArguments.filter(sessionId == row[id])) {
                    if let type = ArgumentType(rawValue: argRow[argType]) {
                        args.append(CounterArgument(
                            id: UUID(uuidString: argRow[id]) ?? UUID(),
                            type: type,
                            text: argRow[argText],
                            severity: argRow[severity],
                            confidenceScore: argRow[confidenceScoreCol],
                            sourceAttribution: argRow[sourceAttrCol]
                        ))
                    }
                }

                var synth: Synthesis?
                for synthRow in try db.prepare(synthesisTable.filter(sessionId == row[id])) {
                    var factChecks: [FactCheckItem] = []
                    if let data = synthRow[factChecksCol].data(using: .utf8) {
                        factChecks = (try? JSONDecoder().decode([FactCheckItem].self, from: data)) ?? []
                    }
                    synth = Synthesis(
                        whatSurvived: synthRow[whatSurvived],
                        whatCollapsed: synthRow[whatCollapsed],
                        needsEvidence: synthRow[needsEvidence],
                        verdict: synthRow[verdict],
                        factChecks: factChecks,
                        overallConfidence: ConfidenceLevel(rawValue: synthRow[overallConfidenceCol]) ?? .medium
                    )
                }

                var sessionRebuttals: [Rebuttal] = []
                for arg in args {
                    let rebuttsForArg = try db.prepare(rebuttals.filter(argumentId == arg.id.uuidString))
                    for rebutRow in rebuttsForArg {
                        sessionRebuttals.append(Rebuttal(
                            id: UUID(uuidString: rebutRow[id]) ?? UUID(),
                            argumentId: arg.id,
                            text: rebutRow[rebuttalText],
                            judgment: RebuttalJudgment(rawValue: rebutRow[judgment]) ?? .weak,
                            confidenceLevel: ConfidenceLevel(rawValue: rebutRow[confidenceLevelCol]) ?? .medium
                        ))
                    }
                }

                loadedSessions.append(GrappleSession(
                    id: sessionUUID,
                    topic: row[topic],
                    originalInput: row[originalInput],
                    counterArguments: args,
                    rebuttals: sessionRebuttals,
                    synthesis: synth,
                    outcome: outcomeVal,
                    debateMode: dmVal,
                    sourceURLs: sourceURLs,
                    factChecks: synth?.factChecks ?? [],
                    createdAt: Date(timeIntervalSince1970: row[createdAt])
                ))
            }

            DispatchQueue.main.async {
                self.sessionsList = loadedSessions
            }
        } catch {
            print("Load sessions error: \(error)")
        }
    }
}
