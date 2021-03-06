    //
//  PTContactViewController.m
//  PTConversationView
//
//  Created by Lasha Dolidze on 4/21/10.
//  Copyright 2010 Picktek LLC. All rights reserved.
//

#import "PTContactViewController.h"
#import "PTConversationHelper.h"

#import "MockDataSource.h"

///////////////////////////////////////////////////////////////////////////////////
// Private Methods
@interface PTContactViewController (Private)
- (void)createContactPicker;
- (void)showPeoplePickerController;
- (void)chooseContact:(id)sender;
@end


#define UIALERTVIEW_SHOWMODAL_BLOCKLOOP_SECONDS 0.01
@implementation UIAlertView (ShowModal)

+ (void) alertWithTitle:(NSString*)title Message:(NSString*)message {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:NULL cancelButtonTitle:@"OK" otherButtonTitles:NULL];
	[alert showModal];
	[alert release];
}

- (void) showModal {
	[self show];
	self.hidden = FALSE;
	while (!self.hidden && self.superview != NULL) [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:UIALERTVIEW_SHOWMODAL_BLOCKLOOP_SECONDS]];
}

@end


@implementation PTContactViewController

@synthesize delegate;
@synthesize textField;



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //[self createContactPicker];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
    [super loadView];
    self.view.backgroundColor = TTSTYLEVAR(backgroundColor);
    
    _scrollView = [[[UIScrollView class] alloc] initWithFrame:self.view.frame];
    _scrollView.backgroundColor = TTSTYLEVAR(backgroundColor);
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _scrollView.canCancelContentTouches = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_scrollView];

    // Add label
    UILabel *label = [[UILabel alloc] init];
    label.text = NSLocalizedString(@"To", @"");
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor grayColor];
    label.numberOfLines = 0;
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.font = [UIFont systemFontOfSize:14.0];
    label.frame = CGRectMake(10, 0, 60.0f, kContactPickerHeight);
    [_scrollView addSubview:label];
    [label release];
    
  
    // Add Text field
    textField = [[TTPickerTextField alloc] initWithFrame:CGRectMake(40, 5.0, self.view.frame.size.width - 110, kContactPickerHeight - 3)];
    //textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    textField.placeholder = NSLocalizedString(@"EnterPhoneNumber", @"");   
    textField.keyboardType = UIKeyboardTypePhonePad;
    textField.backgroundColor = [UIColor clearColor];
    textField.font = [UIFont systemFontOfSize:14.0];
    
    textField.dataSource = [[[MockSearchDataSource alloc] init] autorelease];
    textField.text = @"";
    textField.delegate = self;
    //[textField  performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.5f];
    [self.view addSubview:textField];
    //[textField release];
    
    // Create Add Button
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [addButton setFrame:CGRectMake(self.view.frame.size.width - 35, 9, 32, 30)];
    [addButton addTarget:self action:@selector(chooseContact:) forControlEvents:UIControlEventTouchUpInside];
    addButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
    [_scrollView addSubview:addButton];
    
    //[self layoutViews];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutViews {
    CGFloat y = 0;
    
    for (UIView* view in _scrollView.subviews) {
    //    view.frame = CGRectMake(0, y, self.view.width, view.height);
        y += view.height;
    }
    
    self.view.frame = CGRectMake(0, 0, self.view.width, textField.height + 7);
  //  _scrollView.frame = CGRectMake(0, 0, self.view.width, 200);
    
    NSLog(@"Height %f", textField.height);
    
    //_scrollView.contentSize = CGSizeMake(_scrollView.width, y);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textFieldDidResize:(TTPickerTextField*)textField {
    [self layoutViews];
}

#pragma mark -
#pragma mark Action methods

- (void)chooseContact:(id)sender
{
    textField.text = @"";
    [self.delegate touchPlus:sender];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField_
{
    NSLog(@"Length %@, %d\n", textField_.text, [textField_.text length]);
    
    if(![PTConversationHelper checkPhoneNumber:textField_.text]) {
    
  
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" 
                                                        message:NSLocalizedString(@"PhoneNumberInternational", @"")
                                                       delegate:self 
                                              cancelButtonTitle:NSLocalizedString(@"Dismiss", @"") 
                                              otherButtonTitles:nil];
        [alert showModal];	
        [alert release];
        
        return FALSE;
    }
    
    return TRUE;
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload {
    [super viewDidUnload];
    TT_RELEASE_SAFELY(_scrollView);
    //TT_RELEASE_SAFELY(self.textField);
}

- (void)dealloc {
    [textField release];
    [super dealloc];
}


@end
