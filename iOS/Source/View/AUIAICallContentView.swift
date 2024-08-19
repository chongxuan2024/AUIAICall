//
//  AUIAICallContentView.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit
import AUIFoundation

@objcMembers open class AUIAICallContentView: UIView {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.addSublayer(self.gradientlayer)
        self.addSubview(self.tipsLabel)
        self.addSubview(self.robotStateAni)
        
        self.addSubview(self.subtitleIcon)
        self.addSubview(self.subtitleLabel)
        
        self.subtitleLabel.tappedAction = { [weak self] label in
            self?.openSubtileFullscreen()
        }
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.gradientlayer.frame = CGRect(x: 0, y: self.av_height - 300, width: self.av_width, height: 300)
        
        let hei = self.av_bottom - 228 - 18
        self.robotStateAni.frame = CGRect(x: 0, y: UIView.av_safeTop + 44, width: self.av_width, height: hei - UIView.av_safeTop - 44)
        
        self.tipsLabel.frame = CGRect(x: 0, y: hei, width: self.av_width, height: 18)
        
        self.subtitleIcon.frame = CGRect(x: 50, y: 141, width: 14, height: 14)
        self.subtitleLabel.frame = CGRect(x: self.subtitleIcon.av_right + 8, y: self.subtitleIcon.av_top - 3, width: self.av_width - self.subtitleIcon.av_right - 8 - 48, height: 0)
        self.subtitleLabel.text = self.subtitleLabel.originalText
    }
    
    open var subtileFullscreenView: AUISubtileFullscreenView? = nil
        
    open lazy var tipsLabel: UILabel = {
        let label = UILabel()
        label.textColor = AVTheme.text_strong
        label.textAlignment = .center
        label.font = AVTheme.regularFont(14)
        label.text = ""
        return label
    }()
    
    open lazy var subtitleLabel: AUISubtileReadMoreLabel = {
        let label = AUISubtileReadMoreLabel()
        label.textColor = AVTheme.text_weak
        label.textAlignment = .left
        label.font = AVTheme.regularFont(14)
        label.text = ""
        label.numberOfLines = 4
        label.isHidden = true
//        label.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        return label
    }()
    
    open lazy var subtitleIcon: UIButton = {
        let icon = UIButton()
        icon.setImage(AUIAICallBundle.getCommonImage("ic_sub_asr"), for: .normal)
        icon.setImage(AUIAICallBundle.getCommonImage("ic_sub_llm"), for: .selected)
        icon.isHidden = true
        icon.isUserInteractionEnabled = false
        return icon
    }()
    
    open lazy var gradientlayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.8).cgColor]
        return layer
    }()
    
    open lazy var robotStateAni: AUIAICallRobotStateAnimation = {
        let view = AUIAICallRobotStateAnimation()
        return view
    }()
    
    open func updateSubTitle(enable: Bool, isLLM: Bool, text: String, clear: Bool) {
        self.subtitleIcon.isHidden = !enable
        self.subtitleIcon.isSelected = isLLM
        self.subtitleLabel.isHidden = !enable
        self.subtitleLabel.text = text
        if clear {
//            self.exitSubtileFullscreen()
            
        }
        else {
            self.subtileFullscreenView?.updateSubtitle(subtitle: self.subtitleLabel.originalText)
        }
    }
    
    private func openSubtileFullscreen() {
        self.exitSubtileFullscreen()
        if let container = self.superview {
            
            let view = AUISubtileFullscreenView(frame: container.bounds)
            view.tappedAction = { [weak self] sender in
                self?.exitSubtileFullscreen()
            }
            view.updateSubtitle(subtitle: self.subtitleLabel.originalText)
            container.addSubview(view)
            self.subtileFullscreenView = view
        }
    }
    
    private func exitSubtileFullscreen() {
        self.subtileFullscreenView?.removeFromSuperview()
        self.subtileFullscreenView = nil
    }
}

@objcMembers open class AUISubtileFullscreenView: UIView {
        
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.black.withAlphaComponent(0.8)

        self.addSubview(self.closeBtn)
        self.addSubview(self.titleLabel)
        
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClicked(recognizer:))))
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open lazy var closeBtn: AVBlockButton = {
        let close = AVBlockButton(frame: CGRect(x: self.av_width - 6 - 44, y: UIView.av_safeTop, width: 44, height: 44))
        close.setImage(AVTheme.getImage("ic_close"), for: .normal)
        close.clickBlock = { [weak self] btn in
            self?.tappedAction?(self!)
        }
        return close
    }()
    
    open lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = AVTheme.text_strong
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = AVTheme.regularFont(14)
        label.frame = CGRect(x: 25, y: self.closeBtn.av_bottom + 20, width: self.av_width - 50, height: 0)
        return label
    }()
    
    open func updateSubtitle(subtitle: String?) {
        self.titleLabel.text = subtitle
        self.titleLabel.sizeToFit()
        self.titleLabel.frame = CGRect(x: 25, y: self.closeBtn.av_bottom + 20, width: self.av_width - 50, height: min(self.titleLabel.av_height, self.av_height - self.closeBtn.av_bottom - 20 - UIView.av_safeBottom))
    }
    
    open var tappedAction: ((_ sender: AUISubtileFullscreenView)->Void)? = nil
    
    @objc open func onClicked(recognizer: UIGestureRecognizer) {
        let location = recognizer.location(in: self)
        if self.titleLabel.frame.contains(location) {
            return
        }
        self.tappedAction?(self)
    }
}

@objcMembers open class AUISubtileReadMoreLabel: UILabel {

    var originalText: String?
    var maximumNumberOfLines: Int = 3
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupGesture()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupGesture()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.expandButton.frame = CGRect(x: self.av_width - 40, y: self.av_height - 40, width: 60, height: 60)
    }
    
    private let expandButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(AUIAICallBundle.getCommonImage("ic_subtile_more"), for: .normal)
        button.isHidden = true
        return button
    }()
    
    private func setupGesture() {
        self.isUserInteractionEnabled = true
        self.addSubview(self.expandButton)
        self.expandButton.addTarget(self, action: #selector(toggleText), for: .touchUpInside)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClicked(recognizer:))))
    }
    
    open override var text: String? {
        didSet {
            self.originalText = self.text
            self.truncateTextIfNeeded()
            let width = self.av_width
            self.sizeToFit()
            self.av_width = width
        }
    }
    
    private func truncateTextIfNeeded() {
        self.expandButton.isHidden = true
        guard let originalText = originalText else { return }
        
        let nsText = originalText as NSString
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: self.font!]
        
        let boundingRect = nsText.boundingRect(with: CGSize(width: self.frame.size.width, height: CGFloat.infinity), options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        
        if boundingRect.size.height / self.font.lineHeight > CGFloat(self.maximumNumberOfLines) {
            var truncatedEndIndex = nsText.length
            
            var truncatedText: String?
            
            while truncatedEndIndex > 0 {
                let candidateText = nsText.substring(to: truncatedEndIndex) + "...  >"
                let candidateBoundingRect = (candidateText as NSString).boundingRect(with: CGSize(width: self.frame.size.width, height: CGFloat.infinity), options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
                
                if candidateBoundingRect.size.height / self.font.lineHeight <= CGFloat(maximumNumberOfLines) {
                    truncatedText = nsText.substring(to: truncatedEndIndex) + "..."
                    self.expandButton.isHidden = false
                    break
                }
                
                truncatedEndIndex -= 1
            }
            
            super.text = truncatedText
        }
    }
    
    open var tappedAction: ((_ label: AUISubtileReadMoreLabel)->Void)? = nil

    
    @objc private func toggleText() {
        self.tappedAction?(self)
    }
    
    @objc open func onClicked(recognizer: UIGestureRecognizer) {
        self.tappedAction?(self)
    }
}