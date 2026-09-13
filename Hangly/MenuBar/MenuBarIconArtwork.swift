//
//  MenuBarIconArtwork.swift
//  Hangly
//
//  The drawn status item image for AHK KeyChain.
//

import AppKit
import CoreGraphics

/// Draws the status item: an AHK KeyChain hanging keychain ring with an evil-eye charm.
///
/// A template image, so AppKit owns its colour: it inverts with the menu bar's
/// appearance, dims when the app is in the background and highlights when the menu
/// is open. Drawn from vector geometry rather than shipped as a fixed bitmap so it
/// is exact at every scale factor, Retina density, and menu bar size.
///
/// The charm's pupil is filled while the overlay is showing and an outline while it is
/// hidden, so the menu bar reflects app state at a glance.
///
/// Both states are drawn once and cached, since the view body is re-evaluated far more
/// often than the state changes.
enum MenuBarIconArtwork {
    /// The standard macOS status item square.
    static let side: CGFloat = 18

    private static let showing = render(showing: true)
    private static let hidden = render(showing: false)

    static func image(showing isShowing: Bool) -> NSImage {
        isShowing ? showing : hidden
    }

    // MARK: - Drawing

    private static func render(showing: Bool) -> NSImage {
        let image = NSImage(size: CGSize(width: side, height: side), flipped: true) { _ in
            guard let context = NSGraphicsContext.current?.cgContext else { return false }
            draw(showing: showing, in: context)
            return true
        }
        image.isTemplate = true
        return image
    }

    private static func draw(showing: Bool, in context: CGContext) {
        context.setStrokeColor(NSColor.black.cgColor)
        context.setFillColor(NSColor.black.cgColor)
        context.setLineCap(.round)
        context.setLineJoin(.round)

        let lineWidth: CGFloat = 1.25
        context.setLineWidth(lineWidth)

        let cx: CGFloat = side / 2.0 // 9.0

        // 1. Top Keychain Ring
        let ringCenterY: CGFloat = 3.5
        let ringRadius: CGFloat = 2.4
        let ringRect = CGRect(
            x: cx - ringRadius,
            y: ringCenterY - ringRadius,
            width: ringRadius * 2,
            height: ringRadius * 2
        )
        context.strokeEllipse(in: ringRect)

        // 2. Connector link / jump ring
        let linkTop: CGFloat = 5.2
        let linkBottom: CGFloat = 6.4
        context.beginPath()
        context.move(to: CGPoint(x: cx, y: linkTop))
        context.addLine(to: CGPoint(x: cx, y: linkBottom))
        context.strokePath()

        // 3. Evil-Eye Charm
        let charmCenterY: CGFloat = 11.4
        let bodyRadius: CGFloat = 5.2
        let irisRadius: CGFloat = 3.1
        let pupilRadius: CGFloat = 1.4

        func circle(_ radius: CGFloat) -> CGRect {
            CGRect(
                x: cx - radius,
                y: charmCenterY - radius,
                width: radius * 2,
                height: radius * 2
            )
        }

        // Outer charm body rim
        context.strokeEllipse(in: circle(bodyRadius))

        // Inner iris ring
        context.strokeEllipse(in: circle(irisRadius))

        // Center pupil: filled when overlay is showing, stroked outline when hidden
        if showing {
            context.fillEllipse(in: circle(pupilRadius))
        } else {
            context.strokeEllipse(in: circle(pupilRadius))
        }
    }
}
