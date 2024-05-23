//
//  StatefulTextField.swift
//  StatefulTextField
//
//  Created by Jim Joyce on 5/1/20.
//  Copyright © 2020 Jim Joyce. All rights reserved.
//

#if canImport(UIKit)

import UIKit

@IBDesignable
public class StatefulTextField: UITextField {
    public struct Configuration {
        var untouchedColor = UIColor(red: 240.0/255.0, green: 241.0/255.0, blue: 242.0/255.0, alpha: 1.0)
        var touchedColor   = UIColor(red: 77.0/255.0, green: 125.0/255.0, blue: 238.0/255.0, alpha: 1.0)
        var activeColor    = UIColor(red: 77.0/255.0, green: 125.0/255.0, blue: 238.0/255.0, alpha: 1.0)
        var validColor     = UIColor(red: 33.0/255.0, green: 198.0/255.0, blue: 169.0/255.0, alpha: 1.0)
        var errorColor     = UIColor(red: 249.0/255.0, green: 75.0/255.0, blue: 28.0/255.0, alpha: 1.0)
    }

    enum EditingState: String {
        case untouched, touched, active, error, valid

        var color: UIColor {
            switch self {
            case .untouched, .touched:
                return StatefulTextField.config.untouchedColor
            case .active:
                return StatefulTextField.config.activeColor
            case .valid:
                return StatefulTextField.config.validColor
            case .error:
                return StatefulTextField.config.errorColor
            }
        }
    }

    @IBInspectable open override var font: UIFont? {
        get {
            return super.font
        }
        set {
            super.font = newValue
        }
    }

    static public var config = Configuration()

    typealias ValidationBlock = ((_ value: String) -> Bool)
    open var placeholderLabel: UILabel! = UILabel()
    
    /// If a textField is optional, set this to false when setting properties
    /// 
    var shouldColorChangeForState: Bool = true
    
    var validators: [PresetValidation] = []
    var outsideValidations: ValidationBlock?
    var textValue: Bindable<String> = Bindable<String>("")
    var controlState: Bindable<EditingState> = Bindable<EditingState>(.untouched)

    var hasFormatter: Bool = false

    open override var text: String? {
        set(newValue) {
            var finalVal = newValue
            if hasFormatter {
                finalVal = formatText(from: newValue)
            }

            self.textValue.value = finalVal
            super.text = finalVal
            NotificationCenter.default.post(name: UITextField.textDidChangeNotification, object: self)
        }
        get {
            return super.text
        }
    }

    private weak var _delegate: UITextFieldDelegate?
    open override var delegate: UITextFieldDelegate? {
        get { return self._delegate }
        set {
            self._delegate = newValue
        }
    }

    var formatter: StringFormatters? {
        didSet { hasFormatter = true }
    }

    @IBInspectable open var maxLength: Int = 0
    @IBInspectable open var minLength: Int = 0

    @IBInspectable open var labelText: String? {
        didSet {
            updateLabel()
        }
    }

    @IBInspectable open var updateLive: Bool = true {
        didSet {
            if updateLive && oldValue != self.updateLive {
                addTarget(self, action: #selector(valueDidChange(_:)), for: .editingChanged)
            }
        }
    }

    @IBInspectable open var isRequired: Bool = false {
        didSet {
            if !oldValue && isRequired {
                validators.append(.notEmpty)
            }
        }
    }

    @IBInspectable open var fontSize: CGFloat = 15.0 {
        didSet {
            invalidateIntrinsicContentSize()
            layoutIfNeeded()
        }
    }

    @IBInspectable open var bottomLineOffset: CGFloat = 8.0 {
        didSet {
            constrainBottomLine()
        }
    }

    @IBInspectable open var bottomLineHeight: CGFloat = 1.0 {
        didSet {
            constrainBottomLine()
        }
    }

    @IBOutlet open var validationLabel: UILabel? {
        didSet {
            self.validationLabel?.alpha = 0.0
        }
    }

    var bottomLineWidthAnchor: NSLayoutDimension? {
        didSet {
            constrainBottomLine()
        }
    }

    open var isValid: Bool {
        return controlState.value == .valid
    }

    open var bottomLine: UIView! =  {
        let v = UIView()
        v.isUserInteractionEnabled = false
        v.backgroundColor = EditingState.untouched.color
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    var currentState: EditingState {
        get {
            return controlState.value!
        }
        set {
            self.controlState.value = newValue

            // Check if field should change color for state change (i.e. is field optional?)
            guard self.shouldColorChangeForState else { return }

            UIView.animate(withDuration: 0.15) { [weak self] in
                self?.bottomLine.backgroundColor = self?.controlState.value?.color
                self?.validationLabel?.textColor = self?.controlState.value?.color

                switch self?.controlState.value {
                case .error?:
                    self?.validationLabel?.alpha = 1.0
                    break
                default:
                    self?.validationLabel?.alpha = 0.0
                    break
                }
            }
        }
    }

    //  MARK: Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        afterInitialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        afterInitialize()
    }

    func afterInitialize() {
        delegate = self
        self.textAlignment = .left

        addSubview(bottomLine)
        addSubview(placeholderLabel)

        constrainBottomLine()
        clearButtonMode = .never
        self.textAlignment = .left
        updateLabel()

        addTarget(self, action: #selector(valueDidChange(_:)), for: .editingChanged)
        addTarget(self, action: #selector(didEnterField(_:)), for: .editingDidBegin)
        addTarget(self, action: #selector(didLeaveField(_:)), for: .editingDidEnd)
    }

    private func constrainBottomLine() -> Void {
        bottomLine.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        bottomLine.widthAnchor.constraint(equalTo: bottomLineWidthAnchor ?? widthAnchor).isActive = true
        bottomLine.bottomAnchor.constraint(equalTo: bottomAnchor, constant: bottomLineOffset).isActive = true
        bottomLine.heightAnchor.constraint(equalToConstant: bottomLineHeight).isActive = true
        layoutIfNeeded()
    }

    //  MARK: Life Cycle
    
    @objc func valueDidChange(_ value: Any) -> Void {
        if hasFormatter {
            self.text = formatText(from: self.text)
        }
        self.textValue.value = self.text
        guard updateLive == true else { return }
        adjustStateFromValidations()
    }

    private func formatText(from string: String?) -> String? {
        guard let formatter = formatter, let str = string else { return string }

        return formatter.format(str)
    }

    @objc func didEnterField(_ sender: Any) {
        if currentState == .untouched {
            currentState = .active
        }
    }

    @objc func didLeaveField(_ value: Any) -> Void {
        adjustStateFromValidations()
    }

    func restoreStateFromValue(_ value: String?) -> Void {
        self.text = value
        self.textValue.value = self.text
        if value != nil && value!.count > 0 {
            layoutSubviews()
            self.adjustStateFromValidations()
        }

    }

    //  MARK: Validations
    
    func adjustStateFromValidations() -> Void {
        let isValidated = runValidations()
        if isValidated {
            currentState = .valid
        } else {
            currentState = .error
        }
    }

    private func runValidations() -> Bool {
        var resultAry: [Bool] = validators.map { (val: PresetValidation) in
            return val.run(value: textValue.value).passes
        }

        if let outsideResults = outsideValidations {
            resultAry.append(outsideResults(textValue.value ?? ""))
        }

        return !resultAry.contains(false)
    }

    /// You cant unpack an array into variadic arguments in swift yet,
    /// so the duplicated method signature is required as of right now.
    ///
    func validate(with validationList: [PresetValidation]) -> Void {
        validators = validationList
    }

    func validate(with validationList: PresetValidation...) -> Void {
        validate(with: validationList)
    }

    private func updateLabel() {
        placeholderLabel.text = labelText
        //    placeholderLabel.font = UIFont(name: UIFont.Monsterrat.regular.name, size: fontSize)
        placeholderLabel.textColor = UIColor.gray
        placeholderLabel.textAlignment = .center
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: 1.0).isActive = true
    }

    func updateField() {
        self.layer.borderWidth = 0
        self.layer.borderColor = UIColor.clear.cgColor
    }

    open override var intrinsicContentSize: CGSize {
        return self.placeholderLabel.intrinsicContentSize
    }

    override open func prepareForInterfaceBuilder() {
        if #available(iOS 8.0, *) {
            super.prepareForInterfaceBuilder()
        }
        inputView?.backgroundColor = .black

        borderStyle = .none
        isSelected = true
        invalidateIntrinsicContentSize()
    }
}

extension StatefulTextField : UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard self.maxLength != 0 else { return true }

        let newText = textField.text ?? ""

        // allow delegate to intervene
        guard self._delegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true else {
            return false
        }

        guard let _ = Range(range, in: newText) else { return false }

        let newLength: Int = newText.count + string.count - range.length
        let shouldChange = newLength <= self.maxLength
        return shouldChange
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard _delegate?.textFieldShouldReturn?(textField) ?? true else { return false }

        resignFirstResponder()
        return false
    }
}

#endif
