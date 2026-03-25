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

    // Counter argument columns
    private let sessionId = SQLite.Expression<String>("session_id")
    private let argType = SQLite.Expression<String>("type")
    private let argText = SQLite.Expression<String>("text")
    private let severity = SQLite.Expression<Int>("severity")

    // Rebuttal columns
    private let argumentId = SQLite.Expression<String>("argument_id")
    private let rebuttalText = SQLite.Expression<String>("text")
    private let judgment = SQLite.Expression<String>("judgment")

    // Synthesis columns
    private let whatSurvived = SQLite.Expression<String>("what_survived")
    private let whatCollapsed = SQLite.Expression<String>("what_collapsed")
    private let needsEvidence = SQLite.Expression<String>("needs_evidence")
    private let verdict = SQLite.Expression<String>("verdict")

    @Published var sessionsList: [GrappleSession] = []

    private init() {
        setupDatabase()
        loadSessions()
    }

    private func setupDatabase() {
        do {
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            db = try Connection("\(path)/grapple.sqlite3")
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
        })

        try db.run(counterArguments.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(sessionId)
            t.column(argType)
            t.column(argText)
            t.column(severity)
        })

        try db.run(rebuttals.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(argumentId)
            t.column(rebuttalText)
            t.column(judgment)
        })

        try db.run(synthesisTable.create(ifNotExists: true) { t in
            t.column(sessionId, primaryKey: true)
            t.column(whatSurvived)
            t.column(whatCollapsed)
            t.column(needsEvidence)
            t.column(verdict)
        })
    }

    func saveSession(_ session: GrappleSession) {
        guard let db = db else { return }

        do {
            let insert = sessions.insert(or: .replace,
                id <- session.id.uuidString,
                topic <- session.topic,
                originalInput <- session.originalInput,
                outcome <- session.outcome.rawValue,
                createdAt <- session.createdAt.timeIntervalSince1970
            )
            try db.run(insert)

            for arg in session.counterArguments {
                let argInsert = counterArguments.insert(or: .replace,
                    id <- arg.id.uuidString,
                    sessionId <- session.id.uuidString,
                    argType <- arg.type.rawValue,
                    argText <- arg.text,
                    severity <- arg.severity
                )
                try db.run(argInsert)
            }

            for rebuttal in session.rebuttals {
                let rebuttalInsert = rebuttals.insert(or: .replace,
                    id <- rebuttal.id.uuidString,
                    argumentId <- rebuttal.argumentId.uuidString,
                    rebuttalText <- rebuttal.text,
                    judgment <- rebuttal.judgment.rawValue
                )
                try db.run(rebuttalInsert)
            }

            if let synth = session.synthesis {
                let synthInsert = synthesisTable.insert(or: .replace,
                    sessionId <- session.id.uuidString,
                    whatSurvived <- synth.whatSurvived,
                    whatCollapsed <- synth.whatCollapsed,
                    needsEvidence <- synth.needsEvidence,
                    verdict <- synth.verdict
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
                let sessionUUID = UUID(uuidString: row[id])!
                let outcomeVal = SessionOutcome(rawValue: row[outcome]) ?? .mixed

                var args: [CounterArgument] = []
                for argRow in try db.prepare(counterArguments.filter(sessionId == row[id])) {
                    if let type = ArgumentType(rawValue: argRow[argType]) {
                        args.append(CounterArgument(
                            id: UUID(uuidString: argRow[id])!,
                            type: type,
                            text: argRow[argText],
                            severity: argRow[severity]
                        ))
                    }
                }

                var synth: Synthesis?
                for synthRow in try db.prepare(synthesisTable.filter(sessionId == row[id])) {
                    synth = Synthesis(
                        whatSurvived: synthRow[whatSurvived],
                        whatCollapsed: synthRow[whatCollapsed],
                        needsEvidence: synthRow[needsEvidence],
                        verdict: synthRow[verdict]
                    )
                }

                var sessionRebuttals: [Rebuttal] = []
                for arg in args {
                    for rebutRow in try db.prepare(rebuttals.filter(argumentId == arg.id.uuidString)) {
                        sessionRebuttals.append(Rebuttal(
                            id: UUID(uuidString: rebutRow[id])!,
                            argumentId: arg.id,
                            text: rebutRow[rebuttalText],
                            judgment: RebuttalJudgment(rawValue: rebutRow[judgment]) ?? .weak
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
