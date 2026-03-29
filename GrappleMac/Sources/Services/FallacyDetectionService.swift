import Foundation

/// Shared types re-exported for FallacyDetectionService.
/// All debate types (DetectedFallacy, FallacyType, FallacyReport, etc.)
/// are defined in AIDebateService.swift and available in this module.

actor FallacyDetectionService {
    static let shared = FallacyDetectionService()

    private init() {}

    /// Detects logical fallacies in the given text.
    /// Detects: straw man, ad hominem, false dichotomy, appeal to authority, slippery slope,
    /// circular reasoning, hasty generalization, red herring, appeal to emotion, false causality
    func detectFallacies(in text: String) throws -> [DetectedFallacy] {
        var fallacies: [DetectedFallacy] = []

        fallacies.append(contentsOf: detectStrawMan(in: text))
        fallacies.append(contentsOf: detectAdHominem(in: text))
        fallacies.append(contentsOf: detectFalseDichotomy(in: text))
        fallacies.append(contentsOf: detectAppealToAuthority(in: text))
        fallacies.append(contentsOf: detectSlipperySlope(in: text))
        fallacies.append(contentsOf: detectCircularReasoning(in: text))
        fallacies.append(contentsOf: detectHastyGeneralization(in: text))
        fallacies.append(contentsOf: detectRedHerring(in: text))
        fallacies.append(contentsOf: detectAppealToEmotion(in: text))
        fallacies.append(contentsOf: detectFalseCausality(in: text))

        return fallacies
    }

    /// Detects straw man fallacies — misrepresenting an argument to make it easier to attack
    private func detectStrawMan(in text: String) -> [DetectedFallacy] {
        var detected: [DetectedFallacy] = []

        let strawManPatterns = [
            #"they (think|believe|say|argue) (that )?[A-Z].*is wrong"#,
            #"so you'?re (basically|saying) (that )?[A-Z].*"#,
            #"(misrepresented|mischaracterized|strawman)"#,
        ]

        let lowercased = text.lowercased()
        for pattern in strawManPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(lowercased.startIndex..., in: lowercased)
                let matches = regex.matches(in: lowercased, options: [], range: range)
                for match in matches {
                    if let matchRange = Range(match.range, in: lowercased) {
                        let excerpt = String(text[matchRange])
                        let start = lowercased.distance(from: lowercased.startIndex, to: matchRange.lowerBound)
                        let end = lowercased.distance(from: lowercased.startIndex, to: matchRange.upperBound)
                        detected.append(DetectedFallacy(
                            fallacyType: .strawMan,
                            excerpt: excerpt,
                            explanation: "This appears to misrepresent the opposing view as an extreme or simplified version. A stronger argument would address the strongest form of the opposing position.",
                            positionStart: start,
                            positionEnd: end
                        ))
                    }
                }
            }
        }

        return detected
    }

    /// Detects ad hominem — attacking the person rather than the argument
    private func detectAdHominem(in text: String) -> [DetectedFallacy] {
        var detected: [DetectedFallacy] = []

        let adHominemPatterns = [
            #"(you'?re|that (person|author|thinker)) (just |only |simply )?(wrong|stupid|ignorant|lying|crazy|biased|idiot)"#,
            #"can'?t trust anything from (someone like|people like|a) "#,
            #"(he|she|they) (just|only) (wants to|needs to|must be) "#,
            #"(of course|obviously) (you would|they would) (say that|think that)"#,
        ]

        let lowercased = text.lowercased()
        for pattern in adHominemPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(lowercased.startIndex..., in: lowercased)
                let matches = regex.matches(in: lowercased, options: [], range: range)
                for match in matches {
                    if let matchRange = Range(match.range, in: lowercased) {
                        let excerpt = String(text[matchRange])
                        let start = lowercased.distance(from: lowercased.startIndex, to: matchRange.lowerBound)
                        let end = lowercased.distance(from: lowercased.startIndex, to: matchRange.upperBound)
                        detected.append(DetectedFallacy(
                            fallacyType: .adHominem,
                            excerpt: excerpt,
                            explanation: "This attacks the person making the argument rather than addressing the argument itself. The character or motives of the speaker are irrelevant to whether the argument is logically sound.",
                            positionStart: start,
                            positionEnd: end
                        ))
                    }
                }
            }
        }

        return detected
    }

    /// Detects false dichotomy — presenting only two options when more exist
    private func detectFalseDichotomy(in text: String) -> [DetectedFallacy] {
        var detected: [DetectedFallacy] = []

        let falseDichotomyPatterns = [
            #"(either|you have) (.* or |.*\/.*)"#,
            #"only two (options|choices|possibilities|alternatives)"#,
            #"it'?s (either|this) (or|neither)"#,
            #"(you must|you either|there'?s no choice but to)"#,
            #"black and white"#,
            #"with us or against us"#,
        ]

        let lowercased = text.lowercased()
        for pattern in falseDichotomyPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(lowercased.startIndex..., in: lowercased)
                let matches = regex.matches(in: lowercased, options: [], range: range)
                for match in matches {
                    if let matchRange = Range(match.range, in: lowercased) {
                        let excerpt = String(text[matchRange])
                        let start = lowercased.distance(from: lowercased.startIndex, to: matchRange.lowerBound)
                        let end = lowercased.distance(from: lowercased.startIndex, to: matchRange.upperBound)
                        detected.append(DetectedFallacy(
                            fallacyType: .falseDichotomy,
                            excerpt: excerpt,
                            explanation: "This presents a false binary choice, ignoring that intermediate or alternative options may exist. Reality typically offers more nuance than 'either/or'.",
                            positionStart: start,
                            positionEnd: end
                        ))
                    }
                }
            }
        }

        return detected
    }

    /// Detects appeal to authority — using authority as evidence without justification
    private func detectAppealToAuthority(in text: String) -> [DetectedFallacy] {
        var detected: [DetectedFallacy] = []

        let appealPatterns = [
            #"(experts|scientists|doctors|lawyers|economists) (all )?(say|believe|agree|think) "#,
            #"(studies|research|evidence) (clearly|obviously|shows|prove) "#,
            #"according to (the )?(experts|scientists|studies|research)"#,
            #"as (everyone|anybody|any expert) knows"#,
            #"the (science|scientists|experts) (settled|has proven)"#,
        ]

        let lowercased = text.lowercased()
        for pattern in appealPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(lowercased.startIndex..., in: lowercased)
                let matches = regex.matches(in: lowercased, options: [], range: range)
                for match in matches {
                    if let matchRange = Range(match.range, in: lowercased) {
                        let excerpt = String(text[matchRange])
                        let start = lowercased.distance(from: lowercased.startIndex, to: matchRange.lowerBound)
                        let end = lowercased.distance(from: lowercased.startIndex, to: matchRange.upperBound)
                        detected.append(DetectedFallacy(
                            fallacyType: .appealToAuthority,
                            excerpt: excerpt,
                            explanation: "This appeals to authority without specifying which experts or providing the actual evidence. Citing authority is not a substitute for presenting logical reasoning and empirical support.",
                            positionStart: start,
                            positionEnd: end
                        ))
                    }
                }
            }
        }

        return detected
    }

    /// Detects slippery slope — claiming one event leads to a chain of negative events without evidence
    private func detectSlipperySlope(in text: String) -> [DetectedFallacy] {
        var detected: [DetectedFallacy] = []

        let slipperyPatterns = [
            #"if (we|I|you) (allow|accept|do|start) .*,? (then|next|soon|eventually) (we|I|you|it) (will|would|can)"#,
            #"(one thing|this) (will|can|leads? to) (lead to|cause|result in) (another|disaster|ruin|collapse)"#,
            #"where does it (end|stop)"#,
            #"(down|up) that (road|path|slope|river)"#,
            #"before you know it"#,
            #"(radical|extreme|dangerous) (precedent|slope|path)"#,
            #"the (first |)step (toward|to|on) "#,
        ]

        let lowercased = text.lowercased()
        for pattern in slipperyPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(lowercased.startIndex..., in: lowercased)
                let matches = regex.matches(in: lowercased, options: [], range: range)
                for match in matches {
                    if let matchRange = Range(match.range, in: lowercased) {
                        let excerpt = String(text[matchRange])
                        let start = lowercased.distance(from: lowercased.startIndex, to: matchRange.lowerBound)
                        let end = lowercased.distance(from: lowercased.startIndex, to: matchRange.upperBound)
                        detected.append(DetectedFallacy(
                            fallacyType: .slipperySlope,
                            excerpt: excerpt,
                            explanation: "This assumes one event will inevitably lead to a chain of negative consequences without evidence that each step in the chain is necessary or likely. Each transition requires independent justification.",
                            positionStart: start,
                            positionEnd: end
                        ))
                    }
                }
            }
        }

        return detected
    }

    /// Detects circular reasoning — using the conclusion as a premise
    private func detectCircularReasoning(in text: String) -> [DetectedFallacy] {
        var detected: [DetectedFallacy] = []

        let circularPatterns = [
            #"(it'?s true|true) because (it'?s|it is) true"#,
            #"(the fact|evidence) that (it is|it'?s|this is) (true|real|valid) (is|because) "#,
            #"is (true|right|correct) because (we|I) (say|believe|know) (it is|so)"#,
            #"demonstrates (it is|that it is|its) (true|valid|correct)"#,
            #"by definition,? .* is true because "#,
        ]

        let lowercased = text.lowercased()
        for pattern in circularPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(lowercased.startIndex..., in: lowercased)
                let matches = regex.matches(in: lowercased, options: [], range: range)
                for match in matches {
                    if let matchRange = Range(match.range, in: lowercased) {
                        let excerpt = String(text[matchRange])
                        let start = lowercased.distance(from: lowercased.startIndex, to: matchRange.lowerBound)
                        let end = lowercased.distance(from: lowercased.startIndex, to: matchRange.upperBound)
                        detected.append(DetectedFallacy(
                            fallacyType: .circularReasoning,
                            excerpt: excerpt,
                            explanation: "This argument uses its conclusion as a premise. The evidence offered is essentially the same claim restated, providing no independent support for the conclusion.",
                            positionStart: start,
                            positionEnd: end
                        ))
                    }
                }
            }
        }

        return detected
    }

    /// Detects hasty generalization — drawing broad conclusions from limited evidence
    private func detectHastyGeneralization(in text: String) -> [DetectedFallacy] {
        var detected: [DetectedFallacy] = []

        let hastyPatterns = [
            #"(all|every|each|always|never) (.* )?(are|is|do|have)"#,
            #"(obviously|clearly|everyone|everybody) (knows|believes|agrees)"#,
            #"a (few| couple| handful) (examples?|cases?|instances?) (prove|show|demonstrate)"#,
            #"this (proves|shows|demonstrates) that all "#,
            #"just look at (the|these) (example|case|instance)"#,
            #"no one ever"#,
        ]

        let lowercased = text.lowercased()
        for pattern in hastyPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(lowercased.startIndex..., in: lowercased)
                let matches = regex.matches(in: lowercased, options: [], range: range)
                for match in matches {
                    if let matchRange = Range(match.range, in: lowercased) {
                        let excerpt = String(text[matchRange])
                        if !containsQualifier(word: excerpt) {
                            let start = lowercased.distance(from: lowercased.startIndex, to: matchRange.lowerBound)
                            let end = lowercased.distance(from: lowercased.startIndex, to: matchRange.upperBound)
                            detected.append(DetectedFallacy(
                                fallacyType: .hastyGeneralization,
                                excerpt: excerpt,
                                explanation: "This makes a broad sweeping claim based on limited evidence. Generalizations about 'all', 'always', or 'everyone' require substantial evidence across many cases.",
                                positionStart: start,
                                positionEnd: end
                            ))
                        }
                    }
                }
            }
        }

        return detected
    }

    /// Detects red herring — introducing an irrelevant topic to divert attention
    private func detectRedHerring(in text: String) -> [DetectedFallacy] {
        var detected: [DetectedFallacy] = []

        let redHerringPatterns = [
            #"but (what about|the fact is|let'?s not forget) "#,
            #"speaking of which"#,
            #"that'?s not the real issue"#,
            #"let'?s talk about (what really|the) (matters|counts)"#,
            #"the (real|true|actual) (problem|issue|question) is"#,
            #"ignoring the fact that"#,
            #"aside from the fact that"#,
        ]

        let lowercased = text.lowercased()
        for pattern in redHerringPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(lowercased.startIndex..., in: lowercased)
                let matches = regex.matches(in: lowercased, options: [], range: range)
                for match in matches {
                    if let matchRange = Range(match.range, in: lowercased) {
                        let excerpt = String(text[matchRange])
                        let start = lowercased.distance(from: lowercased.startIndex, to: matchRange.lowerBound)
                        let end = lowercased.distance(from: lowercased.startIndex, to: matchRange.upperBound)
                        detected.append(DetectedFallacy(
                            fallacyType: .redHerring,
                            excerpt: excerpt,
                            explanation: "This introduces an irrelevant topic to divert attention from the original argument. The new topic may be interesting but doesn't address the claim at hand.",
                            positionStart: start,
                            positionEnd: end
                        ))
                    }
                }
            }
        }

        return detected
    }

    /// Detects appeal to emotion — using emotion rather than evidence to persuade
    private func detectAppealToEmotion(in text: String) -> [DetectedFallacy] {
        var detected: [DetectedFallacy] = []

        let emotionPatterns = [
            #"(think about|imagine|picture) (the|all the) (children|people|families|victims)"#,
            #"(heartless|cruel|cold|monster) (not to|to)"#,
            #"(shameful|disgraceful|outrageous|scandalous|terrible)"#,
            #"(love|god|fear|hate|anger|rage|terror|friends|family)"#,
            #"(if you cared|if you were|if you had any) (about|for|like)"#,
            #"would (anyone|any reasonable person) (really|actually|truly)"#,
        ]

        let lowercased = text.lowercased()
        for pattern in emotionPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(lowercased.startIndex..., in: lowercased)
                let matches = regex.matches(in: lowercased, options: [], range: range)
                for match in matches {
                    if let matchRange = Range(match.range, in: lowercased) {
                        let excerpt = String(text[matchRange])
                        let start = lowercased.distance(from: lowercased.startIndex, to: matchRange.lowerBound)
                        let end = lowercased.distance(from: lowercased.startIndex, to: matchRange.upperBound)
                        detected.append(DetectedFallacy(
                            fallacyType: .appealToEmotion,
                            excerpt: excerpt,
                            explanation: "This uses emotional manipulation rather than logical reasoning to persuade. While emotion can be relevant, it should complement — not replace — rational argument and evidence.",
                            positionStart: start,
                            positionEnd: end
                        ))
                    }
                }
            }
        }

        return detected
    }

    /// Detects false causality — assuming cause-and-effect without sufficient evidence
    private func detectFalseCausality(in text: String) -> [DetectedFallacy] {
        var detected: [DetectedFallacy] = []

        let causalityPatterns = [
            #"(prove|show|demonstrate|establish) that .* caused"#,
            #"the (reason|cause) (for|of|behind) .* is"#,
            #"because of (this|that|it)"#,
            #"led to (the|resulted in|caused|created)"#,
            #"as a result of"#,
            #"this (is why|explains why|means that)"#,
        ]

        let lowercased = text.lowercased()
        for pattern in causalityPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(lowercased.startIndex..., in: lowercased)
                let matches = regex.matches(in: lowercased, options: [], range: range)
                for match in matches {
                    if let matchRange = Range(match.range, in: lowercased) {
                        let excerpt = String(text[matchRange])
                        let start = lowercased.distance(from: lowercased.startIndex, to: matchRange.lowerBound)
                        let end = lowercased.distance(from: lowercased.startIndex, to: matchRange.upperBound)
                        detected.append(DetectedFallacy(
                            fallacyType: .falseCausality,
                            excerpt: excerpt,
                            explanation: "This assumes that because two events occurred in sequence, one caused the other. Correlation does not imply causation — both events could have a common cause, or the relationship could be coincidental.",
                            positionStart: start,
                            positionEnd: end
                        ))
                    }
                }
            }
        }

        return detected
    }

    // MARK: - Helpers

    private func containsQualifier(word: String) -> Bool {
        let qualifiers = ["some", "many", "most", "often", "sometimes", "usually", "typically", "perhaps", "may", "might", "could", "likely", "unlikely", "not all", "not every"]
        let lowercased = word.lowercased()
        return qualifiers.contains { lowercased.contains($0) }
    }

    /// Returns a summary report of detected fallacies
    func generateFallacyReport(for text: String) throws -> FallacyReport {
        let fallacies = try detectFallacies(in: text)

        var summary: [String: Int] = [:]
        for fallacy in fallacies {
            let key = fallacy.fallacyType.rawValue
            summary[key] = (summary[key] ?? 0) + 1
        }

        return FallacyReport(
            originalText: text,
            detectedFallacies: fallacies,
            summary: summary,
            overallAssessment: generateAssessment(from: fallacies)
        )
    }

    private func generateAssessment(from fallacies: [DetectedFallacy]) -> String {
        if fallacies.isEmpty {
            return "No significant logical fallacies detected. The argument appears to be logically structured."
        }

        let sortedBySeverity = fallacies.sorted { $0.fallacyType.severity > $1.fallacyType.severity }
        let mostSerious = sortedBySeverity.first!

        return "Detected \(fallacies.count) logical \(fallacies.count == 1 ? "fallacy" : "fallacies"). The most significant issue is the \(mostSerious.fallacyType.rawValue) — \(mostSerious.explanation)"
    }
}
