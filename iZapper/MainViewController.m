//
//  MainViewController.m
//  iZapper
//
//  Created by Rich Porter on 27/10/2013.
//  Copyright (c) 2013 Rich Porter. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController {
    
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    NSString * _ipAddress;
    NSArray *_sxga_sxga, *_hd_sxga, *_hd_hd, *_wuxga_sxga, *_wuxga_hd, *_wuxga_wuxga;
    NSString *_R, *_G, *_B, *_C, *_Y, *_M, *_W, *_shadedRGB, *_chosenProjector, *_userRGB;
    int _gridBoxesWide, _gridBoxesHigh, _centerLeft, _centerRight, _middleTop, _middleBottom, _gridsize, _delayBtwLines;
    double _delayInSeconds;
    NSArray *_projGrid;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	//for testing set default ip manually
    _ipAddress = @"192.168.8.1";
    
    
    //Colour Choices
    _R = @" 255 0 0)";
    _G = @" 0 255 0)";
    _B = @" 0 0 255)";
    _C = @" 0 255 255)";
    _Y = @" 255 255 0)";
    _M = @" 255 0 255)";
    _W = @" 255 255 255)";
    _shadedRGB = @" 64 64 64)";
    
    //_serRGB - Set to red for testing purposes
    //_userRGB = R;
    
    // the following 6 arrays are the values required to draw the blending grids in the varous scenarios
    // proj_grid = {xLineStart, yLineStart, xLineStop, yLineStop, hShadeStart, vShadeStart, hShadeWidth, vShadeHeight, xGrid, yGrid, xPanel, yPanel}
    _sxga_sxga = [NSArray arrayWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:0],[NSNumber numberWithInt:1139],[NSNumber numberWithInt:1049], [NSNumber numberWithInt:512], [NSNumber numberWithInt:640], [NSNumber numberWithInt:24], [NSNumber numberWithInt:118], [NSNumber numberWithInt:1399], [NSNumber numberWithInt:1049], [NSNumber numberWithInt:1400], [NSNumber numberWithInt:1050], nil];
    _hd_sxga = [NSArray arrayWithObjects:[NSNumber numberWithInt:260], [NSNumber numberWithInt:15],[NSNumber numberWithInt:1659],[NSNumber numberWithInt:1064], [NSNumber numberWithInt:528], [NSNumber numberWithInt:901], [NSNumber numberWithInt:24], [NSNumber numberWithInt:118], [NSNumber numberWithInt:1399], [NSNumber numberWithInt:1049], [NSNumber numberWithInt:1920], [NSNumber numberWithInt:1080], nil]; //VERIFIED
    _hd_hd = [NSArray arrayWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:0],[NSNumber numberWithInt:1919],[NSNumber numberWithInt:1079], [NSNumber numberWithInt:512], [NSNumber numberWithInt:897], [NSNumber numberWithInt:55], [NSNumber numberWithInt:126], [NSNumber numberWithInt:1919], [NSNumber numberWithInt:1079], [NSNumber numberWithInt:1920], [NSNumber numberWithInt:1080], nil]; //VERIFIED
    _wuxga_sxga = [NSArray arrayWithObjects:[NSNumber numberWithInt:260], [NSNumber numberWithInt:75],[NSNumber numberWithInt:1659],[NSNumber numberWithInt:1124], [NSNumber numberWithInt:588], [NSNumber numberWithInt:901], [NSNumber numberWithInt:24], [NSNumber numberWithInt:118], [NSNumber numberWithInt:1399], [NSNumber numberWithInt:1049], [NSNumber numberWithInt:1920], [NSNumber numberWithInt:1200], nil];
    _wuxga_hd = [NSArray arrayWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:60],[NSNumber numberWithInt:1919],[NSNumber numberWithInt:1139], [NSNumber numberWithInt:573], [NSNumber numberWithInt:897], [NSNumber numberWithInt:54], [NSNumber numberWithInt:126], [NSNumber numberWithInt:1919], [NSNumber numberWithInt:1179], [NSNumber numberWithInt:1920], [NSNumber numberWithInt:1200], nil];
    _wuxga_wuxga = [NSArray arrayWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:0],[NSNumber numberWithInt:1919],[NSNumber numberWithInt:1199], [NSNumber numberWithInt:577], [NSNumber numberWithInt:897], [NSNumber numberWithInt:46], [NSNumber numberWithInt:126], [NSNumber numberWithInt:1919], [NSNumber numberWithInt:1199], [NSNumber numberWithInt:1920], [NSNumber numberWithInt:1200], nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Flipside View

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
    }
}

- (IBAction)zapAction:(id)sender {
    _ipAddress = @"ipaddress";
    
}

-(void)chooseColour{
    NSInteger theIndex = [_colourSelectSegment selectedSegmentIndex];
    switch (theIndex) {
        case 0:
            _userRGB = _R;
            break;
        case 1:
            _userRGB = _G;
            break;
        case 2:
            _userRGB = _B;
            break;
        case 3:
            _userRGB = _C;
            break;
        case 4:
            _userRGB = _M;
            break;
        case 5:
            _userRGB = _Y;
            break;
        case 6:
            _userRGB = _W;
            break;
        default:
            _userRGB = _R;
            break;
    }
    
}

-(void)whatGrid{
    NSInteger comboBoxIndex = [_gridComboBox indexOfSelectedItem];
    NSLog(@"Combobox Index is %li", (long)comboBoxIndex);
    switch (comboBoxIndex) {
        case 0:
            _projGrid = _sxga_sxga;
            _chosenProjector = @"_sxga_sxga";
            break;
        case 1:
            _projGrid = _hd_sxga;
            _chosenProjector = @"_hd_sxga";
            break;
        case 2:
            _projGrid = _hd_hd;
            _chosenProjector = @"_hd_hd";
            break;
        case 3:
            _projGrid = _wuxga_sxga;
            _chosenProjector = @"_wuxga_sxga";
            break;
        case 4:
            _projGrid = _wuxga_hd;
            _chosenProjector = @"_wuxga_hd";
            break;
        case 5:
            _projGrid = _wuxga_wuxga;
            _chosenProjector = @"_wuxga_wuxga";
            break;
        default:
            _projGrid = _sxga_sxga;
            _chosenProjector = @"_sxga_sxga";
            break;
    }
}


- (void)sendThisMessage:(NSString*)message{
    
    NSString *response  = [NSString stringWithFormat:@"%@", message ];
	NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
	[outputStream write:[data bytes] maxLength:[data length]];
    
    // NSLog(@"%@ just written to ipAddress:%@", response, _ipAddress);
    
}

- (void)initNetworkCommunication {
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, CFBridgingRetain(_ipAddress), 3002, &readStream, &writeStream);
    inputStream = (NSInputStream *)CFBridgingRelease(readStream);
    outputStream = (NSOutputStream *)CFBridgingRelease(writeStream);
    
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [inputStream open];
    [outputStream open];
}


@end
