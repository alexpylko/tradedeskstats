//
//  AccountViewController.h
//  Trade Desk Stats
//
//  Created by Alex Pylko on 11/21/11.
//  Copyright (c) 2011 alexpylko@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Account;

@interface AccountViewController : UITableViewController

@property (nonatomic, retain) UIBarButtonItem * addButtonItem;

@property (nonatomic, retain)  NSMutableArray * accounts;

@property (nonatomic) NSInteger selected;

-(void) attemptShowNewAccountDialog:(id)sender;

-(void) showNewAccountDialog:(id)sender;
-(void) insertNewAccount:(NSString*)name;

-(void) reloadData;

@end
