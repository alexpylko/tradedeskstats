//
//  PFGridViewDemoViewController.m
//  PFGridViewDemo
//
//  Created by YJ Park on 3/8/11.
//  Copyright 2011 PettyFun.com. All rights reserved.
//

#import "DetailViewController.h"
#import "AccountViewController.h"
#import "SBJson.h"
#import "Account.h"

#define JSON_REMOTE_URL @"http://localhost/iphone.php?account=%@"

@implementation DetailViewController

@synthesize demoGridView;
@synthesize maxNumberRows;
@synthesize maxNumberCells;
@synthesize delegate;
@synthesize recordsData;

static CGFloat widthCols [] = { 
    120.0, 45.0, 55.0, 55.0, 65.0 /* 4 */, 
    65.0, 65.0, 120.0, 60.0, 60.0, /* 9 */
    50.0, 44.0, 40.0, 65.0 
};

static const char * headerCols[] = 
{
    "Opentime",
    "Type",
    "Size",
    "Pair",
    "Price",
    "S/L",
    "T/P",
    "Close time",
    "Price",
    "Comm",
    "Taxes",
    "Swap",
    "Pips",
    "Profit"
};

static const char * keysCols[] = 
{ 
    "opentime",
    "type",
    "size",
    "pair",
    "price1",
    "sl",
    "tp",
    "closetime",
    "price2",
    "comm",
    "taxes",
    "swap",
    "pips",
    "profit"
};


- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.

static const NSTimeInterval kRepeatDuration = 60.0;

-(void)viewDidLoad;
{
    [super viewDidLoad];
    maxNumberRows = 10;
    maxNumberCells = 14;
    demoGridView.cellHeight = 30.0f;
    demoGridView.headerHeight = 30.0f;
    
    self.recordsData = [NSArray array];
    
    [self doRequest];
}

- (void) doRequest;
{
    Account * account = [self.delegate.accounts objectAtIndex:self.delegate.selected];
    NSString * accountURL = [NSString stringWithFormat:JSON_REMOTE_URL, account.name];
    
    responseData = [[NSMutableData data] retain];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:accountURL]];
	[[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [self performSelector:_cmd withObject:nil afterDelay:kRepeatDuration];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response 
{
	[responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{
	[responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error occured" message:[NSString stringWithFormat:@"Connection failed: %@", [error description]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection 
{
	[connection release];
    
	NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	[responseData release];
    
    NSDictionary *response = [responseString JSONValue];
    if( [response isKindOfClass:[NSDictionary class]] )
    {
        NSDictionary * result = [response objectForKey:@"result"];
        if( [result isKindOfClass:[NSDictionary class]] )
        {
            NSArray * records = [result objectForKey:@"records"];
            if( [records isKindOfClass:[NSArray class]] )
            {
                self.recordsData = records;
            }
        }
    }
    
    [responseString release];
}

- (void)setRecordsData:(NSArray*)records;
{
    [recordsData release];
    recordsData = [records retain];
    if ( [recordsData count] ) 
    {
        [demoGridView reloadData];
    }
    else
    {
        [self addEmptyLabel];
    }
}

- (void) addEmptyLabel;
{
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 200, 40)];
    label.text = @"No data available";
    label.textColor = [UIColor blackColor];
    [demoGridView addSubview:label];
    [label release];
}

- (void)loadView 
{
    self.wantsFullScreenLayout = YES;
    PFGridView *view = [[PFGridView alloc]
                           initWithFrame:[UIScreen mainScreen].applicationFrame];
    view.dataSource = self;
    view.delegate = self;
    self.view = view;
    self.demoGridView = view;
    
    [view release];
}

-(void)viewDidUnload;
{
    self.delegate = nil;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
{
    [demoGridView reloadData];
}

#pragma mark - PFGridViewDataSource

-(NSUInteger)numberOfSectionsInGridView:(PFGridView *)gridView;
{
    return 1;
}

-(CGFloat)widthForSection:(NSUInteger)section;
{
    return self.view.frame.size.width;
}

-(NSUInteger)numberOfRowsInGridView:(PFGridView *)gridView;
{
    return [self.recordsData count];
}

-(NSUInteger)gridView:(PFGridView *)gridView numberOfColsInSection:(NSUInteger)section;
{
    return maxNumberCells;
}

- (CGFloat)gridView:(PFGridView *)gridView widthForColAtIndexPath:(PFGridIndexPath *)indexPath 
{
    int i = indexPath.col;
    return widthCols[i];
}

- (UIColor *) backgroundColorForIndexPath:(PFGridIndexPath *)indexPath {
    UIColor *result = nil;
    if (indexPath.row % 2) 
    {
        result = [UIColor colorWithRed:235/255.0 green:242/255.0 blue:252/255.0 alpha:1.0];
    } 
    else 
    {
        result = [UIColor colorWithRed:1 green:1 blue:1 alpha:1.0];
    }
    return result;
}

- (PFGridViewCell *)gridView:(PFGridView *)gridView cellForColAtIndexPath:(PFGridIndexPath *)indexPath {
    PFGridViewLabelCell *gridCell = (PFGridViewLabelCell *)[gridView dequeueReusableCellWithIdentifier:@"LABEL"];
    if (gridCell == nil) 
    {
        gridCell = [[[PFGridViewLabelCell alloc] initWithReuseIdentifier:@"LABEL"] autorelease];
        gridCell.textLabel.textAlignment = UITextAlignmentCenter;
        gridCell.selectedBackgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.8 alpha:1];        
    }
    
    NSDictionary * record = [self.recordsData objectAtIndex:indexPath.row];
    NSString * valueString = nil;
    
    if( [record isKindOfClass:[NSDictionary class]] )
    {
        NSString * keyString = [NSString stringWithUTF8String:keysCols[indexPath.col]];
        valueString = [record objectForKey:keyString];
    }
    
    gridCell.textLabel.text = valueString;

    gridCell.normalBackgroundColor = [self backgroundColorForIndexPath:indexPath];
    
    return gridCell;
}

- (UIColor *)headerBackgroundColorForIndexPath:(PFGridIndexPath *)indexPath 
{
    UIColor * result = nil;
    result = [UIColor colorWithRed:192/255.0 green:192/255.0 blue:192/255.0 alpha:1.0];
    return result;
}

- (PFGridViewCell *)gridView:(PFGridView *)gridView headerForColAtIndexPath:(PFGridIndexPath *)indexPath {
    PFGridViewLabelCell *gridCell = (PFGridViewLabelCell *)[gridView dequeueReusableCellWithIdentifier:@"HEADER"];
    if (gridCell == nil) 
    {
        gridCell = [[[PFGridViewLabelCell alloc] initWithReuseIdentifier:@"HEADER"] autorelease];
        gridCell.textLabel.textAlignment = UITextAlignmentCenter;        
    }
    //gridCell.textLabel.text = [NSString stringWithFormat:@"[ %d ]", indexPath.col];
    gridCell.textLabel.text = [NSString stringWithUTF8String:headerCols[indexPath.col]];
    
    gridCell.normalBackgroundColor = [self headerBackgroundColorForIndexPath:indexPath];
    return gridCell;
}


@end
