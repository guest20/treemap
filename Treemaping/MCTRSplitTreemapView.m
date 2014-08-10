//
//  MCTRSplitTreemapView.m
//  Treemap
//
//  Created by Malgorzata Lewandowska on 21/06/14.
//

#import "MCTRSplitTreemapView.h"
#import "MCTRMainManager.h"
#import "MCTRDataStructure.h"

@implementation MCTRSplitTreemapView

- (void)drawRect:(CGRect)rect
{
    if (self.dictWitValues) {
        [self drawSplitMap:self.dictWitValues intRect:self.bounds];
        [self.delegate drawBackground];
    }
}

- (void)drawSplitMap:(M13OrderedDictionary*)dict intRect:(CGRect)rect{
    __block CGFloat weight = 0;
    
    M13MutableOrderedDictionary *tempDictWithRects = [[M13MutableOrderedDictionary alloc] init];
    [dict enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        NSString *ID = (NSString*)[dict keyAtIndex:idx];
        CGFloat val = 0;
        if([object isKindOfClass:[NSNumber class]]){
            [tempDictWithRects setObject:object forKey:ID];
            val = [object floatValue];
        }
        else if([object isKindOfClass:[M13MutableOrderedDictionary class]])
        {
            val = [self recountAreaForDict:object value:0];
            [tempDictWithRects setObject:[NSNumber numberWithFloat:val] forKey:ID];
        }
        weight += val;
    }];
    
    M13MutableOrderedDictionary *L1 = [[M13MutableOrderedDictionary alloc] init], *L2 = [[M13MutableOrderedDictionary alloc] init];
    CGFloat goalWeight = 0;
    BOOL isL2Active = NO;
    NSArray *allKeys = [tempDictWithRects allKeys];
    for (NSString *key in allKeys){
        CGFloat obj = [[tempDictWithRects objectForKey:key] floatValue];
        if ((goalWeight+obj/2.) <= weight/2. && !isL2Active) {
            [L1 setObject:[dict objectForKey:key] forKey:key];
            goalWeight += obj;
        }
        else{
            isL2Active = YES;
            [L2 setObject:[dict objectForKey:key] forKey:key];
        }
    }
    CGFloat firstDimH = self.bounds.size.height,hmax;
    CGFloat dimForScaledWeight;
    CGRect firstRect,secondRect;
    if (rect.size.width >= rect.size.height) {
        hmax = rect.size.height;
        dimForScaledWeight = goalWeight*firstDimH/hmax;
        firstRect = rect;
        firstRect.size.width = dimForScaledWeight;
        secondRect = rect;
        secondRect.origin.x += firstRect.size.width;
        secondRect.size.width -= firstRect.size.width;
        
    }
    else {
        hmax = rect.size.width;
        dimForScaledWeight = goalWeight*firstDimH/hmax;
        firstRect = rect;
        firstRect.size.height = dimForScaledWeight;
        secondRect = rect;
        secondRect.origin.y += firstRect.size.height;
        secondRect.size.height -= firstRect.size.height;
    }
    
    NSInteger lev = [self deepOfHierarchy:dict];
    if (L1.count == 1)
    {
        NSString * key =[[L1 allKeys] firstObject];
        [self drawSplit:firstRect withTitle:key andLevel:lev];
        if ([[L1 objectForKey:key] isKindOfClass:[M13MutableOrderedDictionary class]])
        {
            [self drawSplitMap:[L1 objectForKey:key] intRect:firstRect];
        }
    }
    if (L2.count == 1)
    {
        NSString * key =[[L2 allKeys] firstObject];
        [self drawSplit:secondRect withTitle:key andLevel:lev];
        if ([[L2 objectForKey:[[L2 allKeys] firstObject]] isKindOfClass:[M13MutableOrderedDictionary class]])
        {
            [self drawSplitMap:[L2 objectForKey:[[L2 allKeys] firstObject]] intRect:secondRect];
        }
        
    }
    
    if (L1.count > 1)
    {
        [self drawSplitMap:L1 intRect:firstRect];
    }
    if (L2.count > 1)
    {
        [self drawSplitMap:L2 intRect:secondRect];
    }
}

-(void)drawSplit:(CGRect)rect withTitle:(NSString*)title andLevel:(NSInteger)level{
    if (!self.dictWitRects) self.dictWitRects = [[M13MutableOrderedDictionary alloc] init];
    
    if ([self.dictWitRects objectForKey:title])
    {
        [self.dictWitRects setObject:[NSValue valueWithRect:rect] forKey:[title stringByAppendingString:@"A"]];
    }
    else
    {
        [self.dictWitRects setObject:[NSValue valueWithRect:rect] forKey:title];
    }
    
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetLineWidth(context, level);
    [self setColor:level];
    CGContextAddRect(context, rect);
    CGContextStrokePath(context);
}

@end
