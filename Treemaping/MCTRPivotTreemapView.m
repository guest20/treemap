//
//  MCTRPivotTreemapView.m
//  Treemap
//
//  Created by Malgorzata Lewandowska on 07/06/14.
//

#import "MCTRPivotTreemapView.h"
#import "MCTRMainManager.h"

@implementation MCTRPivotTreemapView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if (self.dictWitValues)
    {
        [self drawPivotMap:self.dictWitValues intRect:self.bounds inDirection:NO];
        [self.delegate drawBackground];
    }
}


- (void)drawPivotMap:(M13OrderedDictionary*)dict intRect:(CGRect)rect inDirection:(BOOL)isVertical{
    CGFloat hmax = rect.size.height;
    if (isVertical) hmax = rect.size.width;
    
    CGFloat firstDimH = self.bounds.size.height;
    
    M13MutableOrderedDictionary *tempDictWithRects = [[M13MutableOrderedDictionary alloc] init];
    [dict enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        NSString *ID = (NSString*)[dict keyAtIndex:idx];
        if([object isKindOfClass:[NSNumber class]]){
            [tempDictWithRects setObject:object forKey:ID];
        }
        else if([object isKindOfClass:[M13MutableOrderedDictionary class]])
        {
            CGFloat val = [self recountAreaForDict:object value:0];
            [tempDictWithRects setObject:[NSNumber numberWithFloat:val] forKey:ID];
        }
    }];
    NSArray *allKeys = [dict allKeys];
    NSString *keyForPivotObject = [allKeys objectAtIndex:ceil(allKeys.count/2.)];
    
    CGFloat pivotEdge = [[tempDictWithRects objectForKey:keyForPivotObject] floatValue];
    pivotEdge = pivotEdge*firstDimH/hmax;
    pivotEdge = sqrtf(pivotEdge*hmax);
    
    CGRect R1,R2,R3,pivotRect;
    CGFloat valuesInR1 = 0, valuesInR2 = 0, valuesInR3 = 0;
    M13MutableOrderedDictionary *L1 = [[M13MutableOrderedDictionary alloc] init], *L2 = [[M13MutableOrderedDictionary alloc] init], *L3 = [[M13MutableOrderedDictionary alloc] init];
    //split rects to lists
    for (int i=0; i<allKeys.count; i++) {
        NSString *key = [allKeys objectAtIndex:i];
        id object = [dict objectForKey:key];
        CGFloat elementVal = [[tempDictWithRects objectForKey:key] floatValue];
        elementVal = elementVal*firstDimH/hmax;
        if (i<[allKeys indexOfObject:keyForPivotObject]){
            valuesInR1 += elementVal;
            [L1 setObject:object forKey:key];
        }
        else if(i>[allKeys indexOfObject:keyForPivotObject]) {   //split to two lists to save aspect ratio of pivot element near 1
            CGFloat valueUnderPivot = (elementVal*hmax)/(hmax - pivotEdge);
            if (valuesInR2 >= pivotEdge)
            {
                valuesInR3 += elementVal;
                [L3 setObject:object forKey:key];
            }
            else {
                valuesInR2+= valueUnderPivot;
                if (valuesInR2 >= pivotEdge) {
                    valuesInR2 -= valueUnderPivot;
                    valuesInR3 += elementVal;
                    [L3 setObject:object forKey:key];
                }
                else{
                    [L2 setObject:object forKey:key];
                }
            }
        }
    }
    
    if (!isVertical)
    {
        R1 = rect;
        R1.size.width = valuesInR1;
        
        //recount areas
        CGSize pivotSize;
        CGFloat p1 = pivotEdge*pivotEdge, p2 = (hmax - pivotEdge)*valuesInR2;
        pivotSize.width = (p1+p2)/hmax;
        pivotSize.height = p1/pivotSize.width;
        
        if ((pivotSize.width+valuesInR1) > rect.size.width && !isVertical)
        {
            pivotSize.width = rect.size.width-valuesInR1;
            pivotSize.height = p1/pivotSize.width;
        }
        
        pivotRect.origin.x = R1.origin.x+R1.size.width;
        pivotRect.origin.y = rect.origin.y;
        pivotRect.size = pivotSize;
        
        R2.origin.x = pivotRect.origin.x;
        R2.origin.y = pivotRect.origin.y+pivotSize.height;
        R2.size.height = rect.size.height - pivotSize.height;
        R2.size.width = p2/R2.size.height;
        
        R3 = rect;
        R3.origin.x = pivotRect.origin.x+pivotRect.size.width;
        R3.size.width = valuesInR3;
    }
    else {
        R1 = rect;
        R1.size.height = valuesInR1;
        
        //recount areas
        CGSize pivotSize;
        CGFloat p1 = pivotEdge*pivotEdge, p2 = (hmax - pivotEdge)*valuesInR2;
        pivotSize.height = (p1+p2)/hmax;
        pivotSize.width = p1/pivotSize.height;
        
        if ((pivotEdge+valuesInR1) > rect.size.height && isVertical)
        {
            pivotSize.height = rect.size.height-valuesInR1;
            pivotSize.width = p1/pivotSize.height;
        }
        
        pivotRect.origin.x = R1.origin.x;
        pivotRect.origin.y = R1.origin.y+R1.size.height;
        pivotRect.size = pivotSize;
        
        R2.origin.x = pivotRect.origin.x+pivotSize.width;
        R2.origin.y = pivotRect.origin.y;
        R2.size.width = rect.size.width - pivotSize.width;
        R2.size.height = p2/R2.size.width;
        
        R3 = rect;
        R3.origin.y = pivotRect.origin.y+pivotRect.size.height;
        R3.size.height = valuesInR3;
    }
    
    NSInteger lev = [self deepOfHierarchy:dict];
    BOOL isVer = NO;
    
    if (L1.count>1) {
        if (R1.size.height > R1.size.width) isVer = YES;
        else isVer = NO;
        [self drawPivotMap:L1 intRect:R1 inDirection:isVer];
    }
    if (L2.count>1) {
        if (R2.size.height > R2.size.width) isVer = YES;
        else isVer = NO;
        [self drawPivotMap:L2 intRect:R2 inDirection:isVer];
    }
    if (L3.count>1){
        if (R3.size.height > R3.size.width) isVer = YES;
        else isVer = NO;
        [self drawPivotMap:L3 intRect:R3 inDirection:isVer];
    }
    [self drawPivot:pivotRect withTitle:keyForPivotObject andLevel:lev];
    
    if (L1.count==1) {
        [self drawPivot:R1 withTitle:[[L1 allKeys] firstObject] andLevel:lev];
        if ([[dict objectForKey:[[L1 allKeys] firstObject]] isKindOfClass:[M13MutableOrderedDictionary class]]){
            if (R1.size.height > R1.size.width) isVer = YES;
            else isVer = NO;
            [self drawPivotMap:[dict objectForKey:[[L1 allKeys] firstObject]] intRect:R1 inDirection:isVer];
        }
    }
    if (L2.count==1) {
        [self drawPivot:R2 withTitle:[[L2 allKeys] firstObject] andLevel:lev];
        if ([[dict objectForKey:[[L2 allKeys] firstObject]] isKindOfClass:[M13MutableOrderedDictionary class]]){
            if (R2.size.height > R2.size.width) isVer = YES;
            else isVer = NO;
            [self drawPivotMap:[dict objectForKey:[[L2 allKeys] firstObject]] intRect:R2 inDirection:isVer];
        }
    }
    if (L3.count==1){
        
        [self drawPivot:R3 withTitle:[[L3 allKeys] firstObject] andLevel:lev];
        if ([[dict objectForKey:[[L3 allKeys] firstObject]] isKindOfClass:[M13MutableOrderedDictionary class]]){
            if (R3.size.height > R3.size.width) isVer = YES;
            else isVer = NO;
            [self drawPivotMap:[dict objectForKey:[[L3 allKeys] firstObject]] intRect:R3 inDirection:isVer];
        }
    }
    
    if ([[dict objectForKey:keyForPivotObject] isKindOfClass:[M13MutableOrderedDictionary class]]){
        if (pivotRect.size.height > pivotRect.size.width) isVer = YES;
        else isVer = NO;
        [self drawPivotMap:[dict objectForKey:keyForPivotObject] intRect:pivotRect inDirection:isVer];
    }
}

-(void)drawPivot:(CGRect)rect withTitle:(NSString*)title andLevel:(NSInteger)level{
    if (!self.dictWitRects) self.dictWitRects = [[M13MutableOrderedDictionary alloc] init];
    [self.dictWitRects setObject:[NSValue valueWithRect:NSRectFromCGRect(rect)] forKey:title];
    
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetLineWidth(context, level);
    [self setColor:level];
    CGContextAddRect(context, rect);
    CGContextStrokePath(context);
}
@end
