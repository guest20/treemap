//
//  MDAppDelegate.m
//  Treemaping
//
//  Created by Malgorzata on 08/08/14.
//

#import "MDAppDelegate.h"
#import "MCTRTreemapView.h"
#import "MCTRSquarifiedTreemapView.h"
#import "MCTRPivotTreemapView.h"
#import "MCTRSplitTreemapView.h"
#import "MCTRStripTreemapView.h"
#import "MCTRDataStructure.h"

@implementation MDAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
}
- (IBAction)chooseFileButtonAction:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO]; // yes if more than one dir is allowed
    
    NSInteger clicked = [panel runModal];
    
    if (clicked == NSFileHandlingPanelOKButton) {
        for (NSURL *url in [panel URLs]) {
            self.textFieldWithDataPath.stringValue = [url absoluteString];
        }
    }
}


- (IBAction)wineQualityButtonAction:(id)sender {
    M13OrderedDictionary *dataSet = [[MCTRDataStructure sharedData] wineQualityData];
    [self createTreemapWithData:dataSet];
    
}
- (IBAction)airPollutionButtonAction:(id)sender {
    M13OrderedDictionary *dataSet = [[MCTRDataStructure sharedData] airPollutionData];
    [self createTreemapWithData:dataSet];
}
- (IBAction)trafficFlowButtonAction:(id)sender {
    M13OrderedDictionary *dataSet = [[MCTRDataStructure sharedData] trafficFlowData];
    [self createTreemapWithData:dataSet];
}
- (IBAction)loadDataFromFileButtonAction:(id)sender {
    if (self.textFieldWithDataPath.stringValue.length == 0)
    {
      NSAlert *alert = [NSAlert alertWithMessageText:@"Wrong path" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Choose file with data you want to visualize"];
        [alert runModal];
        return;
    }
    
   }

- (void)createTreemapWithData:(M13OrderedDictionary*)data  {
    NSView *mainView = self.window.contentView;
    if (self.treemapView)
    {
        [self.treemapView removeFromSuperview];
        self.treemapView = nil;
    }
    switch (self.listViewWithAlgorithms.indexOfSelectedItem) {
        case 0:
            self.treemapView = [[MCTRTreemapView alloc] initWithFrame:CGRectMake(0., 0., mainView.frame.size.width, mainView.frame.size.height)
                                                              andData:data];

            break;
        case 1:
            self.treemapView = [[MCTRSquarifiedTreemapView alloc] initWithFrame:CGRectMake(0., 0., mainView.frame.size.width, mainView.frame.size.height)
                                                              andData:data];
            
            break;
        case 2:
            self.treemapView = [[MCTRStripTreemapView alloc] initWithFrame:CGRectMake(0., 0., mainView.frame.size.width, mainView.frame.size.height)
                                                              andData:data];
            
            break;
        case 3:
            self.treemapView = [[MCTRPivotTreemapView alloc] initWithFrame:CGRectMake(0., 0., mainView.frame.size.width, mainView.frame.size.height)
                                                              andData:data];
            
            break;
        case 4:
            self.treemapView = [[MCTRSplitTreemapView alloc] initWithFrame:CGRectMake(0., 0., mainView.frame.size.width, mainView.frame.size.height)
                                                              andData:data];
            
            break;
            
        default:
            break;
}
    [mainView addSubview:self.treemapView];

}
@end
