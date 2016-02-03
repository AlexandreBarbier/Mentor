//
//  QuestionViewController.swift
//  VoiceSDK
//
//  Created by Alexandre barbier on 26/11/14.
//  Copyright (c) 2014 Poutsch. All rights reserved.
//

import UIKit

public protocol QuestionViewDelegate {
    func applyStyleOnButton(button:UIButton)
    func vote(questionView:QuestionView, vote:Float)
    func skip(questionView:QuestionView)
}

public class QuestionView: UIView {
    public var questionId : Int = -1
    public var question : Question?
    public var questionLabel = UILabel()
    public var questionMedia = UIWebView()
    public var questionAnswers = [VoicePanelButton(), VoicePanelButton(), VoicePanelButton(), VoicePanelButton(), VoicePanelButton()]
    public var questionSlider = UISlider()
    public var sliderUnitLabel = UILabel()
    public var sliderMinValueLabel = UILabel()
    public var sliderMaxValueLabel = UILabel()
    var voteButton = UIButton()
    var skipButton = UIButton()
    public var delegate : QuestionViewDelegate?
    @IBOutlet weak var scrollView: UIScrollView!
    
    public override func awakeFromNib() {
        super.awakeFromNib()

        sliderUnitLabel.textColor = UIColor.whiteColor()
        sliderUnitLabel.font = UIFont.VoiceRegularWithSize(20)
        sliderUnitLabel.textAlignment = NSTextAlignment.Center

        sliderMinValueLabel.textColor = UIColor.whiteColor()
        sliderMinValueLabel.font = UIFont.VoiceRegularWithSize(17)

        sliderMaxValueLabel.textColor = UIColor.whiteColor()
        sliderMaxValueLabel.font = UIFont.VoiceRegularWithSize(17)
        sliderMaxValueLabel.textAlignment = NSTextAlignment.Right
        
        self.questionLabel.textAlignment = NSTextAlignment.Center
        self.questionLabel.textColor = UIColor.whiteColor()
        self.questionLabel.numberOfLines = 0
        self.questionMedia.scrollView.scrollEnabled = false
        self.questionMedia.scalesPageToFit = true
        self.questionMedia.backgroundColor = UIColor.clearColor()
        self.questionLabel.backgroundColor = UIColor.clearColor()
        self.voteButton.setTitle("Vote", forState: UIControlState.Normal)
        self.voteButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.voteButton.layer.borderWidth = 1.0
        self.questionSlider.maximumTrackTintColor = UIColor.VoicePanelBackBlueColor()
        self.voteButton.addTarget(self, action: "vote:", forControlEvents: UIControlEvents.TouchUpInside)
        self.questionSlider.addTarget(self, action: "showVote:", forControlEvents: UIControlEvents.TouchUpInside)
        self.questionSlider.addTarget(self, action: "sliderValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
        var img = UIImage(named: "SliderMin")?.resizableImageWithCapInsets(UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
     
        self.questionSlider.setMinimumTrackImage(img, forState: UIControlState.Normal)
        self.questionSlider.setMaximumTrackImage(UIImage(named: "Slider")?.resizableImageWithCapInsets(UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)), forState: UIControlState.Normal)

        self.questionSlider.thumbTintColor = UIColor.VoicePanelBackBlueColor()

        self.skipButton.addTarget(self, action:"skipQuestion:", forControlEvents: UIControlEvents.TouchUpInside)
        self.skipButton.setTitle("Skip", forState: UIControlState.Normal)
        self.skipButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        
       
        if questionId != -1 {
            Question.getQuestion(questionId, completion: { (local, success, question, error) -> Void in
                if success {
                    self.question = question
                    self.reloadView(true)
                }
            })
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if let q = self.question {
            self.questionLabel.text = q.question
            self.questionLabel.sizeToFit()
            var qFr = self.questionLabel.frame
            if self.questionLabel.frame.size.height < 100 {
                qFr.size.height = 150
            }
            else {
                qFr.size.height += 50
            }
            qFr.origin.x = 8
            qFr.size.width = self.frame.size.width - 16
            self.questionLabel.frame = qFr
            
            var firstY = self.questionLabel.frame.size.height + self.questionLabel.frame.origin.y + 8
            switch q.media.mediaType {
            case .None :
                break
            case .LinkType:
                break
            default:
                var ratio = 0.0
                if q.media.width != 0 {
                    ratio = (Double(self.frame.size.width) * q.media.height) / q.media.width
                }
                self.questionMedia.frame = CGRect(x: 0, y: firstY, width: self.frame.size.width, height: CGFloat(ratio))
                
                
                firstY += CGFloat(ratio + 8)
            }
            switch q.questionType {
            case .Number :
                sliderUnitLabel.frame = CGRect(x: 0, y: firstY, width: self.frame.width - 16, height: 22)

                firstY += 22
                sliderMinValueLabel.frame = CGRect(x: 8, y: firstY, width: 100, height: 22)
                sliderMaxValueLabel.frame = CGRect(x: self.frame.width - 100, y: firstY, width: 100, height: 22)
                firstY += 22
                self.questionSlider.frame = CGRect(x:8,y:firstY, width:self.frame.size.width - 16, height:50)
                let min = q.choices[0].min
                let max = q.choices[0].max
                sliderUnitLabel.text = "\(q.choices[0].unit)"
                sliderMinValueLabel.text = "\(Int(min))"
                sliderMaxValueLabel.text = "\(Int(max))"
                self.questionSlider.maximumValue = max
                self.questionSlider.minimumValue = min
                self.questionSlider.value = (max + min)  / 2
                
            case .Binary, .Multiple:
                for (var i = 0; i < q.choices.count; i++) {
                    
                    var button = self.questionAnswers[i]
                    var fr = button.frame
                    fr.origin.y = firstY
                    button.frame = fr
                    firstY += fr.height + 8
                }
            case .Star :
                for (var i = 0; i < q.choices.count; i++) {
                    
                    var button = self.questionAnswers[i]
                    var fr = button.frame
                    fr.origin.y = firstY
                    button.frame = fr
                    firstY += fr.height + 8
                    
                }
            default:
                fatalError("")
            }
            
            firstY += 32
            self.skipButton.frame = CGRect(x: 8, y: firstY, width: self.frame.width - 16, height: 44.0)
            firstY += 60
        }
    }
    
    func reloadView(canSkip:Bool) -> Void {
        if let q = self.question {

            self.questionLabel.text = q.question
            self.questionLabel.sizeToFit()
            var qFr = self.questionLabel.bounds
            if self.questionLabel.frame.size.height < 100 {
                qFr.size.height = 150
            }
            else {
                qFr.size.height += 50
            }

            qFr.origin.x = 8
            qFr.size.width = self.frame.size.width - 16
            self.questionLabel.frame = qFr
            var animation = CATransition()
            animation.type = kCATransitionPush;
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            animation.duration = 0.4
            animation.subtype = kCATransitionFromRight
            self.questionLabel.layer.addAnimation(animation, forKey: "changeText")
            self.scrollView.addSubview(self.questionLabel)
            var firstY = self.questionLabel.frame.size.height + self.questionLabel.frame.origin.y + 8
            switch q.media.mediaType {
            case .None :
                break
            case .LinkType:
                break
            default:
                self.questionMedia.loadRequest(NSURLRequest(URL: NSURL(string: q.media.link)!))
                var ratio = 0.0
                if q.media.width != 0 {
                    ratio = (Double(self.frame.size.width) * q.media.height) / q.media.width
                }
                self.questionMedia.frame = CGRect(x: 0, y: firstY, width: self.frame.size.width, height: CGFloat(ratio))

                
                self.scrollView.addSubview(self.questionMedia)
                firstY += CGFloat(ratio + 8)
                break
            }
            switch q.questionType {
            case .Number :
                sliderUnitLabel.frame = CGRect(x: 0, y: firstY, width: self.frame.width - 16, height: 22)
                
                firstY += 22
                sliderMinValueLabel.frame = CGRect(x: 8, y: firstY, width: 100, height: 22)
                sliderMaxValueLabel.frame = CGRect(x: self.frame.width - 100, y: firstY, width: 100, height: 22)
                firstY += 22
                self.questionSlider.frame = CGRect(x:8,y:firstY, width:self.frame.size.width - 16, height:50)
                let min = q.choices[0].min
                let max = q.choices[0].max
                sliderUnitLabel.text = "\(q.choices[0].unit)"
                sliderMinValueLabel.text = "\(Int(min))"
                sliderMaxValueLabel.text = "\(Int(max))"
                self.questionSlider.maximumValue = max
                self.questionSlider.minimumValue = min
                self.questionSlider.value = (max + min)  / 2
                self.scrollView.addSubview(sliderUnitLabel)
                self.scrollView.addSubview(sliderMinValueLabel)
                self.scrollView.addSubview(sliderMaxValueLabel)
                self.scrollView.addSubview(self.questionSlider)
            case .Binary, .Multiple:
                for (var i = 0; i < q.choices.count; i++) {
                    let choice = q.choices[i]
                    var button = self.questionAnswers[i]
                    var t =  String(choice.choice)
                    button.setTitle(t, forState:UIControlState.Normal)
                    
                    var fr = button.frame

                    fr.origin.y = firstY
                    button.frame = fr
                    
                    firstY += fr.height + 8
                    self.scrollView.addSubview(button)
                }
            case .Star :
                for (var i = 0; i < q.choices.count; i++) {
                    let choice = q.choices[i]
                    var button = self.questionAnswers[i]
                    button.setTitle(i == 0 ? "\(i + 1) star" : "\(i + 1) stars", forState:UIControlState.Normal)
                    var fr = button.frame
                    fr.origin.y = firstY
                    button.frame = fr
                    firstY += fr.height + 8
                    self.scrollView.addSubview(button)
                }
            default:
                fatalError("")
            }
            if canSkip {
                firstY += 32
                self.skipButton.frame = CGRect(x: 8, y: firstY, width: self.frame.width - 16, height: 44.0)
                firstY += 60
                
                self.scrollView.addSubview(self.skipButton)
            }
            self.scrollView.contentSize = CGSize(width: self.frame.size.width, height: firstY + 50)
//            if scrollView.contentSize.height < self.frame.height {
//                var offset = (self.frame.height - scrollView.contentSize.height) / 2.0
//                scrollView.contentInset = UIEdgeInsets(top: offset, left: 0, bottom: 0, right: 0)
//            }
//            else {
                scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//            }

            UIView.animateKeyframesWithDuration(0.7, delay: 0.0, options: UIViewKeyframeAnimationOptions.CalculationModeLinear, animations: { () -> Void in
                var i : Double = 0
                var nbView : Double = Double(self.scrollView.subviews.count)
                for view in self.scrollView.subviews as [UIView] {
                    i++
                    if view != self.questionLabel && view != self.skipButton {
                        UIView.addKeyframeWithRelativeStartTime((nbView - i) / nbView, relativeDuration: i / nbView, animations: { () -> Void in
                            view.layer.transform = CATransform3DIdentity
                            view.alpha = 1.0
                        })

                    }
                }
                }) { (finished) -> Void in
            }
        }
    }
    
    func vote(sender:UIButton) {
        UIView.animateKeyframesWithDuration(0.7, delay: 0.0, options: UIViewKeyframeAnimationOptions.CalculationModeLinear, animations: { () -> Void in
            var i : Double = 0
            var nbView : Double = Double(self.scrollView.subviews.count)
            for view in self.scrollView.subviews as [UIView] {
                i++
                if view != self.questionLabel && view != self.skipButton {
                    UIView.addKeyframeWithRelativeStartTime((nbView - i) / nbView, relativeDuration: i / nbView, animations: { () -> Void in
                        view.layer.transform = CATransform3DMakeTranslation(-self.frame.size.width, 0.0, 0.0)
                        view.alpha = 0.0
                    })
                }
            }
            }) { (finished) -> Void in
                if finished {
                    self.questionMedia.loadHTMLString("<html></html>", baseURL: nil)
                    for view in self.scrollView.subviews as [UIView]{
                        if view != self.questionLabel && view != self.skipButton {
                            view.removeFromSuperview()
                            view.layer.transform = CATransform3DMakeTranslation(self.frame.size.width, 0.0, 0.0)
                        }
                    }
                    self.scrollView.scrollsToTop = true
                    self.voteButton.transform = CGAffineTransformIdentity
                    var vote : Float = 0.0
                    if let quest = self.question {
                        switch quest.questionType {
                        case .Number :
                            vote = self.questionSlider.value
                            
                        case .Star :
                            vote = Float(sender.tag + 1)
                            
                        case .Multiple, .Binary :
                            vote = Float(sender.tag)
                            
                        default :
                            break
                        }
                        Question.voteOnQuestion(quest.id, vote: vote, completion: { (success, error) -> Void in
                            if let deleg = self.delegate {
                                deleg.vote(self, vote:vote)
                            }
                        })
                    }
                }
        }
    }
    
    func skipQuestion(sender:UIButton) {
        
        UIView.animateKeyframesWithDuration(0.7, delay: 0.0, options: UIViewKeyframeAnimationOptions.CalculationModeLinear, animations: { () -> Void in
            var i : Double = 0
            var nbView : Double = Double(self.scrollView.subviews.count)
            for view in self.scrollView.subviews as [UIView] {
                i++
                if view != self.questionLabel && view != self.skipButton {
                    UIView.addKeyframeWithRelativeStartTime((nbView - i) / nbView, relativeDuration: i / nbView, animations: { () -> Void in
                        view.layer.transform = CATransform3DMakeTranslation(-self.frame.size.width, 0.0, 0.0)
                        view.alpha = 0.0
                    })
                }
                
            }
            }) { (finished) -> Void in
                if finished {
                    self.questionMedia.loadHTMLString("<html></html>", baseURL: nil)
                    for view in self.scrollView.subviews as [UIView] {
                        if view != self.questionLabel && view != self.skipButton {
                            view.removeFromSuperview()
                            view.layer.transform = CATransform3DMakeTranslation(self.frame.size.width, 0.0, 0.0)
                        }
                    }
                    self.scrollView.scrollsToTop = true
                    self.voteButton.transform = CGAffineTransformIdentity
                    if let deleg = self.delegate {
                        deleg.skip(self)
                    }
                }
                
        }
        
    }
    
    func sliderValueChanged(sender:UISlider) {
        sliderUnitLabel.text = "\(Int(sender.value))"
    }
    
    public func setGeneralFont(font:UIFont) {
        self.questionLabel.font = font
        self.skipButton.titleLabel!.font = font
        for button in self.questionAnswers {
            button.titleLabel!.font = font
        }
    }
    
    public func setAnswerFont(font:UIFont) {
        for button in self.questionAnswers {
            button.titleLabel!.font = font
        }
        self.skipButton.titleLabel!.font = font
    }
    
    public func setQuestionFont(font:UIFont) {
        self.questionLabel.font = font
    }
    
    func showVote(sender:UISlider) {
        if CGAffineTransformIsIdentity(self.voteButton.transform) {
            self.voteButton.transform = CGAffineTransformMakeTranslation(0, -self.voteButton.frame.size.height - 8)
        }
    }
    
    public func reloadViewWithQuestion(_quest:Question, canSkip:Bool) {
        self.question = _quest
        self.reloadView(canSkip)
    }
    
    public override func didMoveToWindow() {
        
        super.didMoveToWindow()
        self.questionLabel.frame = CGRect(x:0, y:0, width:self.frame.size.width - 16,height: 50)
        self.questionMedia.frame = CGRect(x:0, y:50, width:self.frame.size.width,height: 50)
        self.questionSlider.frame = CGRect(x:0, y:50, width:self.frame.size.width - 16,height: 50)
        self.voteButton.frame = CGRect(x: 8, y: self.frame.size.height, width: self.frame.size.width - 16, height: 44)
        self.voteButton.layer.cornerRadius = self.voteButton.frame.height / 2
        self.voteButton.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleTopMargin
        self.addSubview(self.voteButton)
        var i = 0
        for button in self.questionAnswers {
            button.tag = i
            button.addTarget(self, action: "vote:", forControlEvents: UIControlEvents.TouchUpInside)
            if let deleg = self.delegate{
                delegate!.applyStyleOnButton(button)
            }
        }
    }
}
