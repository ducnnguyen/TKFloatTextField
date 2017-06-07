//
//  AppTextField.h
//  TFDemoApp
//
//  Created by Abhishek Chandani on 19/05/16.
//  Copyright © 2016 Abhishek. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface PlaceHolderLabel : UILabel
@end

@interface ACFloatingTextField : UITextField
{
    UIView *bottomLineView;
}

@property (nonatomic,strong) UIColor *lineColor;
@property (nonatomic,strong) UIColor *placeHolderColor;
@property (nonatomic,strong) UIColor *selectedPlaceHolderColor;
@property (nonatomic,strong) UIColor *selectedLineColor;

@property (nonatomic,strong) PlaceHolderLabel *labelPlaceholder;

@property (assign) BOOL disableFloatingLabel;
@property (strong, nonatomic) NSString *errorMessage;
@property (assign, nonatomic) BOOL showError;
@property (assign, nonatomic) CGFloat alignRight;

-(instancetype)init;
-(instancetype)initWithFrame:(CGRect)frame;

-(void)setTextFieldPlaceholderText:(NSString *)placeholderText;
-(void)updateTextField:(CGRect)frame;

@end
