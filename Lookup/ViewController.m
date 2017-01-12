//
//  ViewController.m
//  Lookup
//
//  Created by Robert Bastian on 05.05.13.
//  Copyright (c) 2013 Robert Bastian. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)go:(id)sender
{
    [textField resignFirstResponder];
    NSObject* result = [self lookup:[textField text]];
    if ([result isKindOfClass:[NSError class]])
    {
        NSError* e = (NSError*) result;
        [self showMessage:e.domain withTitle:@"Error"];
    }
    else
    {
        NSArray* a = (NSArray*) result;
        [self showMessage:[a objectAtIndex:1] withTitle:[a objectAtIndex:0]];
    }
}

- (id)lookup:(NSString*)input
{
    NSString* number = [input stringByReplacingOccurrencesOfString:@" " withString:@""];
    const char* num = [number cStringUsingEncoding:1];
    
    if (num[0] == '0' && num[1] == '0')
    {
        if (num[2] == '4' && num[3] == '9')
            number = [number stringByReplacingOccurrencesOfString:@"0049" withString:@"0"];
        else
            return [NSError errorWithDomain:@"Not a german number" code:1 userInfo:nil];
    }

    if (num[0] == '+')
    {
        if (num[1] == '4' && num[2] == '9')
            number = [number stringByReplacingOccurrencesOfString:@"+49" withString:@"0"];
        else
            return [NSError errorWithDomain:@"Not a german number" code:1 userInfo:nil];
    }
    
    NSError *error = [[NSError alloc] init];
    
    NSString* url = [@"http://mobil.dastelefonbuch.de/r/" stringByAppendingString:number];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:url]];
    [request addValue:@"1" forHTTPHeaderField:@"j"];
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if([responseCode statusCode] != 200)
        return [NSError errorWithDomain:@"Couldn't complete request" code:2 userInfo:nil];

    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:oResponseData options:0 error:&error];
    @try
    {
        NSDictionary* hit = [[[[json objectForKey:@"hitlist"] objectAtIndex:0] objectForKey:@"hits"]objectAtIndex:0];
        NSMutableArray* nameLang =  [NSMutableArray arrayWithArray:[[[hit objectForKey:@"name"] stringByReplacingOccurrencesOfString:@"u." withString:@"oder"] componentsSeparatedByString:@" "]];
        if ([[[nameLang lastObject] substringToIndex:3] isEqualToString:@"Dr."])
        {
            NSString* title = [nameLang lastObject];
            [nameLang removeLastObject];
            [nameLang insertObject:title atIndex:1];
        }
        [nameLang addObject:[nameLang objectAtIndex:0]];
        [nameLang removeObjectAtIndex:0];
        NSString* name = [nameLang componentsJoinedByString:@" "];
        return [NSArray arrayWithObjects:name,[[hit objectForKey:@"address"] objectForKey:@"location"], nil];
    }
    @catch (NSException * e)
    {
        return [NSError errorWithDomain:@"No match" code:3 userInfo:nil];
    }
}

- (void)showMessage: (NSString*) message withTitle: (NSString*) title
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}

@end
