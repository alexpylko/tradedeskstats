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

#define JSON_REMOTE_URL @"http://impartdata.com/systemstructure/services/trades.json.php?user=%@&sys=Timed"


@interface DetailViewController ()
- (void)addEmptyLabel;
- (void)removeEmptyLabel;
- (void)calculateAutoResizeFactorWithOrientation:(UIInterfaceOrientation)orientation;
@property (nonatomic) CGFloat autoSizeFactor;
@end

@implementation DetailViewController

@synthesize demoGridView;
@synthesize maxNumberRows;
@synthesize maxNumberCells;
@synthesize delegate;
@synthesize recordsData;
@synthesize activityIndicator;
@synthesize availLabel;
@synthesize autoSizeFactor;

static CGFloat widthCols [] = { 
    80.0, 
    60.0, 
    60.0, 
    140.0, 
    140.0,
    110.0, 
    110.0, 
    80.0
};

static const char * headerCols[] = 
{
    "Instrument",
    "Type",
    "Size",
    "Open Time",
    "Close Time",
    "Price1",
    "Price2",
    "Profit"
};

static const char * keysCols[] = 
{ 
    "instrument",
    "type",
    "size",
    "opentime",
    "closetime",
    "price1",
    "price2",
    "profit"
};


- (void)dealloc
{
    [activityIndicator release];
    [availLabel release];
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
    maxNumberCells = 8;
    demoGridView.cellHeight = 30.0f;
    demoGridView.headerHeight = 30.0f;
    
    [self calculateAutoResizeFactorWithOrientation:[self interfaceOrientation]];
    
    Account * account = [self.delegate.accounts objectAtIndex:self.delegate.selected];
    self.title = account.name;
    
    self.wantsFullScreenLayout = YES;
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                            target:self
                                                                            action:@selector(refresh)];
    self.navigationItem.rightBarButtonItem = button;
    [button release];
    
    self.recordsData = [NSArray array];
    
    [self refresh];
}

- (void) refresh;
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [activityIndicator startAnimating];
    
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
    [activityIndicator stopAnimating];
//    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error occured" message:[NSString stringWithFormat:@"Connection failed: %@", [error description]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [alert show];
//    [alert release];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection 
{
    [activityIndicator stopAnimating];
	[connection release];
    
	NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	[responseData release];
    
    NSDictionary *response = [responseString JSONValue];
    if( [response isKindOfClass:[NSDictionary class]] )
    {
        NSArray * records = [response objectForKey:@"trades"];
        if( [records isKindOfClass:[NSArray class]] )
        {
            self.recordsData = records;
        }
    }
    
    if ( [recordsData count] )
    {
        [self removeEmptyLabel];
    }
    else
    {
        [self addEmptyLabel];
    }
    
    [responseString release];
}

- (void) addEmptyLabel;
{
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 320, 40)];
    label.text = @"No data available for the chosen account";
    label.textColor = [UIColor blackColor];
    [self.view addSubview:label];
    self.availLabel = label;
    [label release];
}

- (void) removeEmptyLabel;
{
    [self.availLabel removeFromSuperview];
}

- (void)setRecordsData:(NSArray*)records;
{
    [recordsData release];
    recordsData = [records retain];
    if ( [recordsData count] ) 
    {
        [demoGridView reloadData];
    }
}
    

-(void)viewDidUnload;
{
    self.delegate = nil;
    self.activityIndicator = nil;
    self.availLabel = nil;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

-(NSInteger)tableWidth;
{
    NSInteger total = 0;
    for ( NSInteger i = 0; i < maxNumberCells; ++i) 
    {
        total += widthCols[i];
    }
    return total;
}

-(void)calculateAutoResizeFactorWithOrientation:(UIInterfaceOrientation)orientation;
{
    autoSizeFactor = 1;
    if ( UIInterfaceOrientationIsLandscape(orientation) )
    {
        NSInteger width = [self tableWidth];
        CGRect frame = [[UIScreen mainScreen] applicationFrame];
        if ( ( width < frame.size.height ) && ( width > 0 ) )
        {
            autoSizeFactor = frame.size.height / width;
        }
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
{
    if ( UIInterfaceOrientationIsPortrait(fromInterfaceOrientation))
    {
        [self calculateAutoResizeFactorWithOrientation:UIInterfaceOrientationLandscapeLeft];
    }
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
    return (widthCols[i] * autoSizeFactor);
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
