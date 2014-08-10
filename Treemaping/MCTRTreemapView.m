//
//  MCTRTreemapView.m
//  Treemap
//
//  Created by Malgorzata Lewandowska on 06/06/14.
//

#import "MCTRTreemapView.h"
#import "MCTRMainManager.h"

@interface MCTRTreemapView()
@end

@implementation MCTRTreemapView

- (instancetype) initWithFrame:(CGRect)frame andData:(M13OrderedDictionary*)rectsArray{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.dictWitValues = [rectsArray mutableCopy];
        self.dictWitRects = [[M13MutableOrderedDictionary alloc] init];
        self.oldVals = [[M13OrderedDictionary alloc] initWithOrderedDictionary:rectsArray copyEntries:YES];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if (self.dictWitValues) {
        if (!self.dictWitRects) self.dictWitRects = [[M13MutableOrderedDictionary alloc] init];
        [self drawOneLevel:self.dictWitValues dir:NO inRect:self.bounds];
        [self.delegate drawBackground];
    }
}


- (void) drawOneLevel:(M13MutableOrderedDictionary*)dict dir:(BOOL)isVertical inRect:(CGRect)rect{
    NSInteger level = [self deepOfHierarchy:dict];
    __block CGFloat areaForObj;
    __block float x=rect.origin.x, y=rect.origin.y;
    
    [dict enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        NSString *ID = (NSString*)[dict keyAtIndex:idx];
        if ([object isKindOfClass:[NSNumber class]])
        {
            NSNumber *valNum = object;
            areaForObj = [valNum floatValue];
        }
        else if ([object isKindOfClass:[M13MutableOrderedDictionary class]]) {
            areaForObj = [self recountAreaForDict:object value:0];
        }
        CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
        CGContextSetLineWidth(context, level);
        [self setColor:level];
        CGRect rectangle;
        if (isVertical){
            rectangle = CGRectMake(x,y,rect.size.width,areaForObj);
            y+=areaForObj;
        }
        else{
            rectangle = CGRectMake(x,y,areaForObj,rect.size.height);
            x += areaForObj;
        }
        CGContextAddRect(context, rectangle);
        [self.dictWitRects setObject:[NSValue valueWithRect:NSRectFromCGRect(rectangle)] forKey:ID];
        CGContextStrokePath(context);
        if ([object isKindOfClass:[M13MutableOrderedDictionary class]]) {
            M13OrderedDictionary *dict = [[MCTRMainManager lastMainManager] recountTestDataForDirection:!isVertical
                                                                                                andDict:object
                                                                                                andArea:self.bounds];
            [self drawOneLevel:[dict mutableCopy] dir:!isVertical inRect:rectangle];
        }
    }];
}

- (CGFloat) recountAreaForDict:(M13MutableOrderedDictionary*)dict value:(CGFloat)value{
    NSArray *allVal = [dict allObjects];
    for (id object in allVal){
        if ([object isKindOfClass:[NSNumber class]])
        {
            NSNumber *valNum = object;
            CGFloat objVal = [valNum floatValue];
            value +=objVal;
        }
        else if ([object isKindOfClass:[M13MutableOrderedDictionary class]]) {
            
            value+=[self recountAreaForDict:object value:value];
        }
    }
    return value;
}

- (NSInteger) deepOfHierarchy:(M13OrderedDictionary*)dict {
    NSInteger max=0;
    NSInteger temp_depth;
    NSArray *allVal = [dict allObjects];
    for (id object in allVal){
        if ([object isKindOfClass:[M13MutableOrderedDictionary class]]){
            temp_depth=[self deepOfHierarchy:object];
            if (max<temp_depth) {
                max=temp_depth;
            }
        }
    }
    return max+1;
}

- (void) setColor:(NSInteger)level{
  CGContextRef context =  [[NSGraphicsContext currentContext] graphicsPort];
    switch (level) {
        case 1:
            CGContextSetStrokeColorWithColor(context, [NSColor blackColor].CGColor);
            break;
        case 2:
            CGContextSetStrokeColorWithColor(context, [NSColor blackColor].CGColor);
        default:
            break;
    }
}

- (CGFloat) averageAspectRatio:(M13MutableOrderedDictionary*)dictWitRects{
    CGFloat sum = 0;
    for (id object in [dictWitRects allObjects]){
        sum+= [self aspectRatioOfRect:NSRectToCGRect([object rectValue])];
    }
    return sum/dictWitRects.count;
}

- (CGFloat)aspectRatioOfRect:(CGRect)rect{
    return MIN(rect.size.height,rect.size.width)/MAX(rect.size.height,rect.size.width);
}

@end
