//
//  AccountViewController.m
//  Trade Desk Stats
//
//  Created by Alex Pylko on 11/21/11.
//  Copyright (c) 2011 alexpylko@gmail.com. All rights reserved.
//

#import "AccountViewController.h"
#import "DetailViewController.h"
#import "DatabaseStorage.h"
#import "UIAlertView+Prompt.h"

@implementation AccountViewController

@synthesize addButtonItem;
@synthesize accounts;
@synthesize selected;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    self.selected = -1;
    
    UIBarButtonItem * buttonItem = [[UIBarButtonItem alloc]
                 initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self
                 action:@selector(attemptShowNewAccountDialog:)];
    
    self.addButtonItem = buttonItem;
    
    [buttonItem release];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.addButtonItem, 
                                               self.editButtonItem, nil];

    [self reloadData];
}

-(void) reloadData;
{
    self.accounts = [[DatabaseStorage sharedDatabaseStorage] accounts];
    [self.tableView reloadData];
}

-(void) attemptShowNewAccountDialog:(id)sender;
{
    if ( [self isEditing] ) 
    {
        [self setEditing:FALSE animated:TRUE];
        
        [self performSelector:@selector(showNewAccountDialog:) withObject:sender afterDelay:0.3];
    }
    else
    {
        [self showNewAccountDialog:sender];
    }
}

-(void) showNewAccountDialog:(id)sender;
{
    UIAlertView * alert = [[[UIAlertView alloc] initWithTitle:@"New account" message:@"Please type account\n\n\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil] autorelease];
    
    [alert prompt];
}

-(void) alertView:(UIAlertView*) alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if ( 1 == buttonIndex ) 
    {
        [self performSelector:@selector(insertNewAccount:) withObject:[alertView promptValue] afterDelay:0.3];
    }
}

-(void) insertNewAccount:(NSString*)name;
{
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:self.accounts.count inSection:0];
    
    Account * account = [[DatabaseStorage sharedDatabaseStorage] accountWithName:name];
    
    [self.accounts insertObject:account atIndex:indexPath.row];
    
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
}

- (void)viewDidUnload
{
    self.accounts = nil;
    self.addButtonItem = nil;
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.accounts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.frame];
    imageView.image = [UIImage imageNamed:@"LightGrey.png"];
    cell.backgroundView = imageView;
    [imageView release];
    
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    cell.textLabel.text = [[self.accounts objectAtIndex:indexPath.row] name];
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) 
    {
        [[DatabaseStorage sharedDatabaseStorage] deleteAccount:[self.accounts objectAtIndex:indexPath.row]];
        
        [self.accounts removeObjectAtIndex:indexPath.row];
        
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
    }   
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return UITableViewCellEditingStyleDelete;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog( @"prepareForSegue %@", segue.identifier );
    if ( [segue.identifier isEqualToString:@"details"] ) 
    {
        NSIndexPath * indexPath = [self.tableView indexPathForSelectedRow];
        self.selected = indexPath.row;

        DetailViewController * controller = (DetailViewController*) segue.destinationViewController;
        controller.delegate = self;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selected = indexPath.row;
}

@end
