//
//  MCTRStripTreemapView.m
//  Treemap
//
//  Created by Malgorzata Lewandowska on 07/06/14.
//

#import "MCTRStripTreemapView.h"
#import "MCTRMainManager.h"

@implementation MCTRStripTreemapView

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
        [self drawSquarifiedTreemapForDict:self.dictWitValues inRect:self.bounds];
        [self.delegate drawBackground];
    }
}

- (void) drawSquarifiedTreemapForDict:(M13MutableOrderedDictionary*)dict inRect:(CGRect)rect{
    M13MutableOrderedDictionary *dictOfDicts = [[M13MutableOrderedDictionary alloc] init];
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
            [dictOfDicts setObject:object forKey:ID];
        }
    }];
    
    NSArray *keysArray = [tempDictWithRects allKeys];
    M13MutableOrderedDictionary *finalDictWithRects = [[M13MutableOrderedDictionary alloc] init];
    M13MutableOrderedDictionary * rectsDict = [[M13MutableOrderedDictionary alloc] init]; //rects with fixed layout
    CGRect rectangle = rect;
    CGFloat edge = 0;
    CGFloat value = 0;
    CGFloat aspectRatio = 0;
    BOOL isVertical  = NO;
    CGFloat old = self.bounds.size.height;
    M13MutableOrderedDictionary *rectToFixSize = [[M13MutableOrderedDictionary alloc] init];
    for (NSString *ID in keysArray) {
    NewRow:
        value = [[tempDictWithRects objectForKey:ID] floatValue];
        rectangle.origin = rect.origin;
        if (isVertical) {
            //vertical
            edge = rect.size.width;
            rectangle.size.width = edge;
            rectangle.size.height = value*old/edge;
        }
        else {
            //horizontal
            edge = rect.size.height;
            rectangle.size.width = value*old/edge;
            rectangle.size.height = edge;
            
        }
        [rectToFixSize setObject:[NSValue valueWithRect:NSRectFromCGRect(rectangle)] forKey:ID];
        rectsDict = [self fixLayout:rectToFixSize inDirection:isVertical edge:edge origin:rect.origin];
        if (aspectRatio!=0)
        {
            CGFloat newAspectRatio = [self averageAspectRatio:rectsDict];
            if (aspectRatio > newAspectRatio) {
                //change direction
                [rectsDict removeObjectForKey:ID];
                [rectToFixSize removeObjectForKey:ID];
                rectsDict = [self fixLayout:rectToFixSize inDirection:isVertical edge:edge origin:rect.origin];
                CGRect areaForRects = [self recountAreaForDictionaryWithRects:rectsDict];
                //recount new row or column
                CGFloat x,y; //new column
                if (isVertical){
                    x = areaForRects.origin.x;
                    y = areaForRects.origin.y+areaForRects.size.height;
                    rect.origin.y = y;
                    rect.size.height-=areaForRects.size.height;
                }
                else {
                    x = areaForRects.origin.x + areaForRects.size.width;
                    y = areaForRects.origin.y+areaForRects.size.height;
                    rect.origin.x = x;
                    rect.size.width -= areaForRects.size.width;
                }
                //  isVertical = !isVertical;
                [self addObjectsFromDict:rectsDict ToDict:finalDictWithRects];
                [rectsDict removeAllObjects];
                [rectToFixSize removeAllObjects];
                aspectRatio = 0;
                goto NewRow;
            }
        }
        aspectRatio = [self averageAspectRatio:rectsDict];
    }
    [self addObjectsFromDict:rectsDict ToDict:finalDictWithRects];
    
    CGFloat level = [self deepOfHierarchy:dict];
    [finalDictWithRects enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        NSString *ID = (NSString*)[finalDictWithRects keyAtIndex:idx];
        CGRect rectToDraw = NSRectToCGRect([object rectValue]);
        CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
        CGContextSetLineWidth(context, level);
        [self setColor:level];
        CGContextAddRect(context, rectToDraw);
//        UILabel *label = [[UILabel alloc] initWithFrame:rectToDraw];
//        [self setLabelFont:level inLabel:label];
//        label.text = ID;
//        [self addSubview:label];
        CGContextStrokePath(context);
        if (!self.dictWitRects) self.dictWitRects = [[M13MutableOrderedDictionary alloc] init];
        [self.dictWitRects setObject:object forKey:ID];
    }];
    
    [dictOfDicts enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        NSString *ID = (NSString*)[dictOfDicts keyAtIndex:idx];
        CGRect rect = NSRectToCGRect([[finalDictWithRects objectForKey:ID] rectValue]);
        [self drawSquarifiedTreemapForDict:object inRect:rect];
    }];
}

- (void) addObjectsFromDict:(M13MutableOrderedDictionary*)dictWithRects ToDict:(M13MutableOrderedDictionary*)finalDict{
    [dictWithRects enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        NSString *ID = (NSString*)[dictWithRects keyAtIndex:idx];
        [finalDict setObject:[NSValue valueWithRect:[object rectValue]] forKey:ID];
    }];
}

- (M13MutableOrderedDictionary*) fixLayout:(M13MutableOrderedDictionary*)rects inDirection:(BOOL)isVertical edge:(CGFloat)edge origin:(CGPoint)origin{
    M13MutableOrderedDictionary *rectsWithFixedLayout = [[M13MutableOrderedDictionary alloc] init];
    CGFloat sumOfValues = 0;
    CGFloat onUnit = 0;
    for (id object in [rects allObjects]) {
        CGRect rect = NSRectToCGRect([object rectValue]);
        if (isVertical) sumOfValues+=rect.size.height;
        else  sumOfValues+= rect.size.width;
    }
    onUnit = edge/sumOfValues;
    
    __block CGFloat coordinate = 0;
    __block BOOL first = YES;
    [rects enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        NSString *ID = (NSString*)[rects keyAtIndex:idx];
        CGRect rect = NSRectToCGRect([object rectValue]);
        if (isVertical)
        {
            if (first){coordinate  = origin.x;first = NO;}
            CGFloat field = rect.size.width*rect.size.height;
            rect.origin.x = coordinate;
            rect.size.width = rect.size.height*onUnit;
            rect.size.height = field/rect.size.width;
            coordinate += rect.size.width;
        }
        else{
            if(first){coordinate = origin.y; first = NO;}
            CGFloat field = rect.size.width*rect.size.height;
            rect.origin.y = coordinate;
            rect.size.height = rect.size.width*onUnit;
            rect.size.width = field/rect.size.height;
            coordinate += rect.size.height;
        }
        [rectsWithFixedLayout setObject:[NSValue valueWithRect:NSRectFromCGRect(rect)] forKey:ID];
    }];
    return rectsWithFixedLayout;
}

- (CGRect) recountAreaForDictionaryWithRects:(M13MutableOrderedDictionary*)rects{
    CGRect area = CGRectZero;
    for (id object in [rects allObjects])
    {
        CGRect rect = NSRectToCGRect([object rectValue]);
        if (CGRectEqualToRect(CGRectZero, area)){
            area = rect;
        }
        else {
            area = CGRectUnion(area, rect);
        }
    }
    return area;
}

- (void) scaledValues:(BOOL)isVertical inDict:(M13MutableOrderedDictionary*)dict keysArray:(NSArray*)keysArr{
    CGFloat scaleFactor;
    if (isVertical) scaleFactor = self.bounds.size.height/self.bounds.size.width;
    else scaleFactor = self.bounds.size.width/self.bounds.size.height;
    
    for (NSString* ID in keysArr) {
        CGFloat val  = [[dict objectForKey:ID] floatValue]*scaleFactor;
        [dict setObject:[NSNumber numberWithFloat:val] forKey:ID];
    }
}
@end
