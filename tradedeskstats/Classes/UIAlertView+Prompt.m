//
//  UIAlertView+Prompt.m
//  Trade Desk Stats
//
//  Created by Alex Pylko on 11/25/11.
//  Copyright (c) 2011 alexpylko@gmail.com. All rights reserved.
//

#import "UIAlertView+Prompt.h"

@implementation UIAlertView (Prompt)

static NSInteger textFieldIdentifier = 100;

-(NSString*)promptValue;
{
    UITextField * field = (UITextField*)[self viewWithTag:100];
    return [field text];
}

-(void)prompt;
{
    UITextField * textField = [[UITextField alloc ] initWithFrame:CGRectMake( 20.0, 80.0, 245.0, 30.0 )];
    textField.backgroundColor = [UIColor whiteColor];
    textField.textColor = [UIColor blackColor];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.tag = textFieldIdentifier;
    [self addSubview:textField];
    [textField release];
    [self show];
}

@end
