//
//  AUIAICallSettingPanel.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit
import AUIFoundation

public typealias AUIAICallSettingSelectedBlock = (_ item: AUIAICallVoiceItem) -> Void
public typealias AUIAICallSettingEnableBlock = (_ isOn: Bool) -> Void
public typealias AUIAICallSettingDefaultBlock = (_ sender: AUIAICallSettingPanel) -> Void


@objcMembers open class AUIAICallSettingPanel: AVBaseCollectionControllPanel {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.titleView.text = AUIAICallBundle.getString("Settings")
        
        self.collectionView.frame = CGRect(x: 0, y: 0, width: self.contentView.av_width, height: self.contentView.av_height)
        self.collectionView.register(AUIAICallSoundCell.self, forCellWithReuseIdentifier: "cell")
        
        self.collectionView.addSubview(self.collectionHeaderView)
        self.collectionHeaderView.addSubview(self.normalModeBtn)
        self.collectionHeaderView.addSubview(self.pptModeBtn)
        self.collectionHeaderView.addSubview(self.interruptSwitch)
        self.collectionHeaderView.addSubview(self.voiceprintSettingView)
        self.collectionHeaderView.addSubview(self.voiceIdSwitch)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.updateLayout()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override class func panelHeight() -> CGFloat {
        return 448
    }
    
    public var enableVoiceIdSwitch: Bool = true {
        didSet {
            self.voiceIdSwitch.isHidden = !self.enableVoiceIdSwitch
        }
    }
    
    public var enableVoiceprintSwitch: Bool = true {
        didSet {
            self.voiceprintSettingView.isHidden = !self.enableVoiceprintSwitch
        }
    }
    
    
    public var isVoiceprintRegisted: Bool = true {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    open lazy var collectionHeaderView: UIView = {
        let view = UIView()
        return view
    }()
    
    open lazy var normalModeBtn: AVBlockButton = {
        let btn = AVBlockButton()
        btn.setTitle(AUIAICallBundle.getString("Natural Conversation Mode"), for: .normal)
        btn.titleLabel?.numberOfLines = 0
        btn.titleLabel?.font = AVTheme.regularFont(12)
        btn.setTitleColor(AVTheme.text_strong, for: .normal)
        btn.setBorderColor(AVTheme.border_ultraweak, for: .normal)
        btn.setBorderColor(AVTheme.colourful_border_strong, for: .selected)
        btn.setBackgroundImage(AUIAICallBundle.getCommonImage("ic_mode_normal"), for: .normal)
        btn.setBackgroundImage(AUIAICallBundle.getCommonImage("ic_mode_select"), for: .selected)
        btn.layer.borderWidth = 1
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 8
        btn.clickBlock = {[weak self] btn in
            if btn.isSelected {
                return
            }
            self?.onPushToTalkSwitchChanged(ptt: false)
            self?.pushToTalkBlock?(false)
        }
        return btn
    }()
    
    open lazy var pptModeBtn: AVBlockButton = {
        let btn = AVBlockButton()
        btn.setTitle(AUIAICallBundle.getString("Push to Talk Mode"), for: .normal)
        btn.titleLabel?.font = AVTheme.regularFont(12)
        btn.setTitleColor(AVTheme.text_strong, for: .normal)
        btn.setBorderColor(AVTheme.border_ultraweak, for: .normal)
        btn.setBorderColor(AVTheme.colourful_border_strong, for: .selected)
        btn.setBackgroundImage(AUIAICallBundle.getCommonImage("ic_mode_normal"), for: .normal)
        btn.setBackgroundImage(AUIAICallBundle.getCommonImage("ic_mode_select"), for: .selected)
        btn.layer.borderWidth = 1
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 8
        btn.clickBlock = {[weak self] btn in
            if btn.isSelected {
                return
            }
            self?.onPushToTalkSwitchChanged(ptt: true)
            self?.pushToTalkBlock?(true)
        }
        return btn
    }()
        
    open lazy var interruptSwitch: AVSwitchBar = {
        let view = AVSwitchBar()
        view.titleLabel.text = AUIAICallBundle.getString("Smart Interrupt")
        view.infoLabel.text = AUIAICallBundle.getString("Interrupt AI Based on Sound and Environment")
        view.lineView.isHidden = true
        view.onSwitchValueChanged = { [weak self] bar in
            self?.interruptBlock?(bar.switchBtn.isOn)
        }
        return view
    }()
    
    
    open lazy var voiceprintSettingView: AUIAICallVoiceprintSettingView = {
        let view = AUIAICallVoiceprintSettingView()
        view.voiceprintSwitch.onSwitchValueChanged = { [weak self] bar in
            self?.voiceprintBlock?(bar.switchBtn.isOn)
        }
        view.removeBtn.clickBlock = { [weak self] btn in
            if let self = self {
                self.clearVoiceprintBlock?(self)
            }
        }
        return view
    }()
    
    open lazy var voiceIdSwitch: AVSwitchBar = {
        let view = AVSwitchBar()
        view.titleLabel.text = AUIAICallBundle.getString("Choose Voice Tone")
        view.infoLabel.text = AUIAICallBundle.getString("New Voice Tone Will Take Effect in Next Response")
        view.switchBtn.isHidden = true
        view.lineView.isHidden = true
        return view
    }()
    
    open lazy var itemList: [AUIAICallVoiceItem] = {
        var list = [AUIAICallVoiceItem]()
        let item0 = AUIAICallVoiceItem()
        item0.voiceId = "zhixiaobai"
        item0.voiceName = AUIAICallBundle.getString("Zhi Xiaobai")
        item0.icon = "ic_sound_bai"
        list.append(item0)
        
        let item1 = AUIAICallVoiceItem()
        item1.voiceId = "zhixiaoxia"
        item1.voiceName = AUIAICallBundle.getString("Zhi Xiaoxia")
        item1.icon = "ic_sound_xia"
        list.append(item1)
        
        let item2 = AUIAICallVoiceItem()
        item2.voiceId = "abin"
        item2.voiceName = AUIAICallBundle.getString("Abin")
        item2.icon = "ic_sound_bin"
        list.append(item2)
        
        return list
    }()
    
    private var selectItem: AUIAICallVoiceItem? = nil {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    open var pushToTalkBlock: AUIAICallSettingEnableBlock? = nil
    open var applyPlayBlock: AUIAICallSettingSelectedBlock? = nil
    open var interruptBlock: AUIAICallSettingEnableBlock? = nil
    open var voiceprintBlock: AUIAICallSettingEnableBlock? = nil
    open var clearVoiceprintBlock: AUIAICallSettingDefaultBlock? = nil

    open var config: AUIAICallConfig? = nil {
        didSet {
            self.refreshUI()
        }
    }

    private func refreshUI() {
        self.onPushToTalkSwitchChanged(ptt: self.config?.enablePushToTalk == true)

        self.interruptSwitch.switchBtn.isOn = self.config?.enableVoiceInterrupt ?? true
        self.voiceprintSettingView.voiceprintSwitch.switchBtn.isOn = self.config?.useVoiceprint ?? true
        self.selectItem = self.itemList.first { item in
            return item.voiceId == self.config?.agentVoiceId
        }
        
        self.setNeedsLayout()
    }
    
    private func onPushToTalkSwitchChanged(ptt: Bool) {
        self.normalModeBtn.isSelected = !ptt
        self.pptModeBtn.isSelected = ptt
        self.interruptSwitch.isHidden = ptt
        
        self.setNeedsLayout()
    }
    
    private func updateLayout() {
        
        var top: CGFloat = 16
        
        let w = (self.collectionView.av_width - 20 - 20 - 16) / 2.0
        self.normalModeBtn.frame = CGRect(x: 20, y: top, width: w, height: 52)
        self.pptModeBtn.frame = CGRect(x: self.normalModeBtn.av_right + 16, y: top, width: w, height: 52)
        top = self.pptModeBtn.av_bottom + 16
        
        self.interruptSwitch.frame = CGRect(x: 0, y: top, width: self.collectionView.av_width, height: 74)
        top = self.interruptSwitch.isHidden ? top : self.interruptSwitch.av_bottom
        
        let vp = 74.0 + (self.isVoiceprintRegisted ? 48.0 : 0.0)
        self.voiceprintSettingView.frame = CGRect(x: 0, y: top, width: self.collectionView.av_width, height: vp)
        top = self.voiceprintSettingView.isHidden ? top : self.voiceprintSettingView.av_bottom + 6
        
        self.voiceIdSwitch.frame = CGRect(x: 0, y: top, width: self.collectionView.av_width, height: 50)
        top = self.voiceIdSwitch.isHidden ? top : self.voiceIdSwitch.av_bottom
        
        self.collectionHeaderView.frame = CGRect(x: 0, y: -top, width: self.collectionView.av_width, height: top)
        self.collectionView.contentInset = UIEdgeInsets(top: top, left: 0, bottom: 0, right: 0)
        self.collectionView.setContentOffset(CGPoint(x: 0, y: -top), animated: false)
    }
}

extension AUIAICallSettingPanel {
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !self.enableVoiceIdSwitch {
            return 0
        }
        return self.itemList.count
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.contentView.av_width, height: 48)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: UIView.av_safeBottom, right: 0)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! AUIAICallSoundCell
        cell.item = self.itemList[indexPath.row]
        cell.isApplied = cell.item == self.selectItem
        cell.applyBtn.clickBlock = {[weak self, weak cell] sender in
            if let item = cell?.item {
                self?.applyPlayBlock?(item)
                self?.selectItem = item
            }
        }
        return cell
    }
}


@objcMembers open class AUIAICallVoiceItem: NSObject {
    open var voiceId: String = ""
    open var voiceName: String = ""
    open var icon: String = ""
}

@objcMembers open class AUIAICallSoundCell: UICollectionViewCell {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.titleLabel)
        self.addSubview(self.iconView)
        self.addSubview(self.applyBtn)
        self.addSubview(self.appliedIcon)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.iconView.frame = CGRect(x: 20, y: (self.av_height - 32) / 2, width: 32, height: 32)
        
        self.applyBtn.sizeToFit()
        let width = self.applyBtn.av_width + 24
        self.applyBtn.frame = CGRect(x: self.av_width - width - 20, y: (self.av_height - 22) / 2, width: width, height: 22)
        self.appliedIcon.frame = self.applyBtn.frame
        
        self.titleLabel.frame = CGRect(x: self.iconView.av_right + 12, y: 0, width: self.applyBtn.av_left - self.iconView.av_right - 12 - 12, height: self.av_height)
    }
    
    open lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = AVTheme.regularFont(12)
        label.textColor = AVTheme.text_strong
        return label
    }()
    
    open lazy var iconView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 6
        view.layer.masksToBounds = true
        view.layer.borderWidth = 0.5
        view.layer.borderColor = AVTheme.border_weak.cgColor
        return view
    }()
    
    
    open lazy var applyBtn: AVBlockButton = {
        let btn = AVBlockButton()
        btn.layer.cornerRadius = 11
        btn.layer.masksToBounds = true
        btn.layer.borderWidth = 1.0
        btn.titleLabel?.font = AVTheme.regularFont(12)
        btn.setImage(nil, for: .normal)
        btn.setBorderColor(AVTheme.border_strong, for: .normal)
        btn.setTitleColor(AVTheme.text_strong, for: .normal)
        btn.setTitle(AUIAICallBundle.getString("Use"), for: .normal)
        btn.isHidden = false
        return btn
    }()
    
    open lazy var appliedIcon: UIImageView = {
        let view = UIImageView()
        view.contentMode = .center
        view.image = AUIAICallBundle.getCommonImage("ic_sound_apply")
        view.isHidden = true
        return view
    }()
    
    open var item: AUIAICallVoiceItem? {
        didSet {
            self.titleLabel.text = self.item?.voiceName
            self.iconView.image = AUIAICallBundle.getImage(self.item?.icon)
        }
    }
    
    open var isApplied: Bool = false {
        didSet {
            self.applyBtn.isHidden = self.isApplied
            self.appliedIcon.isHidden = !self.isApplied
        }
    }
}

@objcMembers open class AUIAICallVoiceprintSettingView: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.clipsToBounds = true
        self.addSubview(voiceprintSwitch)
        self.addSubview(self.stateView)
        self.stateView.addSubview(self.titleLabel)
        self.stateView.addSubview(self.removeBtn)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.voiceprintSwitch.frame = CGRect(x: 0, y: 0, width: self.av_width, height: 74)
        self.stateView.frame = CGRect(x: 20, y: self.voiceprintSwitch.av_bottom, width: self.av_width - 20 - 20, height: 48)
        self.titleLabel.sizeToFit()
        self.titleLabel.center = CGPoint(x: self.titleLabel.av_width / 2.0 + 16, y: self.stateView.av_height / 2.0)
        
        self.removeBtn.sizeToFit()
        let width = self.removeBtn.av_width + 24
        self.removeBtn.frame = CGRect(x: self.stateView.av_width - width - 16, y: (self.stateView.av_height - 22) / 2, width: width, height: 22)
    }
    
    open var voiceprintIsApply: Bool = false {
        didSet {
            self.stateView.isHidden = !self.voiceprintIsApply
        }
    }
    
    open lazy var voiceprintSwitch: AVSwitchBar = {
        let view = AVSwitchBar()
        view.titleLabel.text = AUIAICallBundle.getString("Voiceprint(Invitation for Testing)")
        view.infoLabel.text = AUIAICallBundle.getString("The AI only uses your voice as input.")
        view.lineView.isHidden = true
        return view
    }()
    
    open lazy var stateView: UIView = {
        let view = UIView()
        view.backgroundColor = AVTheme.fill_weak
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()
    
    open lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = AVTheme.regularFont(12)
        label.textColor = AVTheme.text_weak
        label.text = AUIAICallBundle.getString("Detected speaking")
        return label
    }()
    
    open lazy var removeBtn: AVBlockButton = {
        let btn = AVBlockButton()
        btn.layer.cornerRadius = 11
        btn.layer.masksToBounds = true
        btn.layer.borderWidth = 1.0
        btn.titleLabel?.font = AVTheme.regularFont(12)
        btn.setImage(nil, for: .normal)
        btn.setBorderColor(AVTheme.border_strong, for: .normal)
        btn.setTitleColor(AVTheme.text_strong, for: .normal)
        btn.setTitle(AUIAICallBundle.getString("Remove Voiceprint"), for: .normal)
        btn.isHidden = false
        return btn
    }()
}
