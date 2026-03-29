import SwiftUI
import AppKit

class GrappleMenuBarController {
    private var popover: NSPopover?
    private var statusItem: NSStatusItem?

    init() {
        setupStatusItem()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "brain.head.profile", accessibilityDescription: "Grapple")
            button.action = #selector(togglePopover)
            button.target = self
        }
    }

    @objc private func togglePopover() {
        if let popover = popover {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                showPopover()
            }
        } else {
            popover = NSPopover()
            popover?.contentViewController = NSHostingController(rootView: MenuBarPopoverView())
            popover?.behavior = .transient
            popover?.animates = true
            showPopover()
        }
    }

    private func showPopover() {
        if let button = statusItem?.button {
            popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
}

struct MenuBarPopoverView: View {
    @State private var quickInput: String = ""
    @State private var showingAlert: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Grapple")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Button {
                    NSApplication.shared.hide(nil)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)

            Divider()

            // Quick paste input
            VStack(alignment: .leading, spacing: 8) {
                Text("Quick Challenge")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)

                TextEditor(text: $quickInput)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.primary)
                    .scrollContentBackground(.hidden)
                    .frame(height: 60)
                    .padding(6)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )

                Button {
                    guard !quickInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                    // Copy to pasteboard and notify
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(quickInput, forType: .string)
                    showingAlert = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        showingAlert = false
                        quickInput = ""
                    }
                } label: {
                    HStack {
                        Image(systemName: "bolt.fill")
                        Text("Copy for Challenge")
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(MacTheme.challenge)
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)
                .disabled(quickInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                if showingAlert {
                    Text("Copied! Open GrappleMac to paste.")
                        .font(.system(size: 11))
                        .foregroundColor(MacTheme.success)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .padding(12)

            Divider()

            // Actions
            VStack(spacing: 1) {
                Button {
                    openMainApp()
                } label: {
                    HStack {
                        Image(systemName: "macwindow")
                        Text("Open GrappleMac")
                        Spacer()
                    }
                    .font(.system(size: 12))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)

                Divider()

                Button {
                    NSApplication.shared.terminate(nil)
                } label: {
                    HStack {
                        Image(systemName: "power")
                        Text("Quit")
                        Spacer()
                    }
                    .font(.system(size: 12))
                    .foregroundColor(.red)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(width: 260)
        .background(MacTheme.surface)
    }

    private func openMainApp() {
        NSWorkspace.shared.launchApplication("GrappleMac")
    }
}

// Menu bar extra entry point
// To use: Add to your App's main.swift or configure as a separate target
// This controller can be instantiated from the main app to provide menu bar functionality
