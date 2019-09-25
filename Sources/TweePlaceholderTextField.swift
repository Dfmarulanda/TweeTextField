//  Created by Daniel Marulanda on 21/09/19.
//  Copyright © 2017-2019 Oleg Hnidets. All rights reserved.
//

import UIKit

/// An object of the class has a customized placeholder label which has animations on the beginning and ending editing.
open class TweePlaceholderTextField: UITextField {

	/// Animation type when a user begins editing.
	public enum MinimizationAnimationType {
		/** Sets minimum font size immediately when a user begins editing. */
		case immediately

		// May have performance issue on first launch. Need to investigate how to fix.
		/** Sets minimum font size step by step during animation transition when a user begins editing. */
		case smoothly
	}

	/// Default is `immediately`.
	public var minimizationAnimationType: MinimizationAnimationType = .immediately

	/// Minimum font size for the custom placeholder.
	@IBInspectable public var minimumPlaceholderFontSize: CGFloat = 12
	/// Original (maximum) font size for the custom placeholder.
	@IBInspectable public var originalPlaceholderFontSize: CGFloat = 17
	/// Placeholder animation duration.
	@IBInspectable public var placeholderDuration: Double = 0.5
	/// Color of custom placeholder.
	@IBInspectable public var placeholderColor: UIColor? {
		get {
			return placeholderLabel.textColor
		} set {
			placeholderLabel.textColor = newValue
		}
	}
	/// The styled string for a custom placeholder.
	public var attributedTweePlaceholder: NSAttributedString? {
		get {
			return placeholderLabel.attributedText
		} set {
			setAttributedPlaceholderText(newValue)
		}
	}

	/// The string that is displayed when there is no other text in the text field.
	@IBInspectable public var tweePlaceholder: String? {
		get {
			return placeholderLabel.text
		} set {
			setPlaceholderText(newValue)
		}
	}

    /// The custom insets for `placeholderLabel` relative to the text field.
	public var placeholderInsets: UIEdgeInsets = .zero

	/// Custom placeholder label. You can use it to style placeholder text.
	public private(set) lazy var placeholderLabel = UILabel()

	///	The current text that is displayed by the label.
	open override var text: String? {
		didSet {
			setPlaceholderSizeImmediately()
		}
	}

	/// The styled text displayed by the text field.
	open override var attributedText: NSAttributedString? {
		didSet {
			setPlaceholderSizeImmediately()
		}
	}

	/// The technique to use for aligning the text.
	open override var textAlignment: NSTextAlignment {
		didSet {
			placeholderLabel.textAlignment = textAlignment
		}
	}

	/// The font used to display the text.
	open override var font: UIFont? {
		didSet {
			configurePlaceholderFont()
		}
	}

	private let placeholderLayoutGuide = UILayoutGuide()
	private var leadingPlaceholderConstraint: NSLayoutConstraint?
	private var trailingPlaceholderConstraint: NSLayoutConstraint?

	private var placeholderGuideHeightConstraint: NSLayoutConstraint?

	// MARK: Methods

    /// :nodoc:
	public override init(frame: CGRect) {
		super.init(frame: frame)

		initializeSetup()
	}

    /// :nodoc:
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)

		initializeSetup()
	}

    /// :nodoc:
	open override func awakeFromNib() {
		super.awakeFromNib()

		configurePlaceholderLabel()
		setPlaceholderSizeImmediately()
	}

    /// :nodoc:
	open override func layoutSubviews() {
		super.layoutSubviews()

		configurePlaceholderInsets()
	}

	private func initializeSetup() {
		configurePlaceholderLabel()
	}

	// Need to investigate and make code better.
	private func configurePlaceholderLabel() {
		placeholderLabel.textAlignment = textAlignment
		configurePlaceholderFont()
	}

	private func configurePlaceholderFont() {
		placeholderLabel.font = font ?? placeholderLabel.font
		placeholderLabel.font = placeholderLabel.font.withSize(originalPlaceholderFontSize)
	}

	private func setPlaceholderText(_ text: String?) {
		addPlaceholderLabelIfNeeded()
		placeholderLabel.text = text

		setPlaceholderSizeImmediately()
	}

	private func setAttributedPlaceholderText(_ text: NSAttributedString?) {
		addPlaceholderLabelIfNeeded()
		placeholderLabel.attributedText = text

		setPlaceholderSizeImmediately()
	}

	private func setPlaceholderSizeImmediately() {
			enablePlaceholderHeightConstraint()
			placeholderLabel.font = placeholderLabel.font.withSize(minimumPlaceholderFontSize)
	}


	private func addPlaceholderLabelIfNeeded() {
		if placeholderLabel.superview != nil {
			return
		}

		addSubview(placeholderLabel)
		placeholderLabel.translatesAutoresizingMaskIntoConstraints = false

		leadingPlaceholderConstraint = placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor)
		leadingPlaceholderConstraint?.isActive = true

		trailingPlaceholderConstraint = placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
		trailingPlaceholderConstraint?.isActive = true

		addLayoutGuide(placeholderLayoutGuide)

		NSLayoutConstraint.activate([
			placeholderLayoutGuide.leadingAnchor.constraint(equalTo: leadingAnchor),
			placeholderLayoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor),
			placeholderLayoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor)
			])


		let centerYConstraint = placeholderLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
		centerYConstraint.priority = .defaultHigh

        NSLayoutConstraint.activate([
            placeholderLabel.bottomAnchor.constraint(equalTo: placeholderLayoutGuide.topAnchor, constant: 16),
            centerYConstraint
            ])

		configurePlaceholderInsets()
	}

	private func configurePlaceholderInsets() {
		let placeholderRect = self.placeholderRect(forBounds: bounds)

		leadingPlaceholderConstraint?.constant = placeholderRect.origin.x + placeholderInsets.left

		let trailing = bounds.width - placeholderRect.maxX
		trailingPlaceholderConstraint?.constant = -trailing - placeholderInsets.right
	}

	private func enablePlaceholderHeightConstraint() {
        if placeholderLayoutGuide.owningView == nil {
            return
        }

		placeholderGuideHeightConstraint?.isActive = false
		placeholderGuideHeightConstraint = placeholderLayoutGuide.heightAnchor.constraint(equalTo: heightAnchor)
		placeholderGuideHeightConstraint?.isActive = true
	}
}
