//
//  PFGridViewDemoViewController.h
//  PFGridViewDemo
//
//  Created by YJ Park on 3/8/11.
//  Copyright 2011 PettyFun.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFGridView.h"

@class AccountViewController;

@interface DetailViewController : UIViewController <PFGridViewDataSource, PFGridViewDelegate> {
    IBOutlet PFGridView *demoGridView;
    NSMutableData * responseData;
}

@property (nonatomic, retain) IBOutlet PFGridView * demoGridView;

@property (nonatomic) NSUInteger maxNumberRows;

@property (nonatomic) NSUInteger maxNumberCells;

@property (nonatomic,retain) NSArray * recordsData;

@property (nonatomic, retain) AccountViewController * delegate;

- (void) addEmptyLabel;
- (void) doRequest;

@end
