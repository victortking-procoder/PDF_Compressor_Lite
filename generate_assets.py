#!/usr/bin/env python3
"""
Generate all required assets for PDF Compressor Lite
"""

from PIL import Image, ImageDraw, ImageFont
import math

# Color scheme - Professional Blue
PRIMARY_COLOR = (33, 150, 243)  # #2196F3
DARK_BLUE = (25, 118, 210)  # #1976D2
ACCENT_COLOR = (255, 193, 7)  # #FFC107
WHITE = (255, 255, 255)
LIGHT_GRAY = (240, 240, 240)
DARK_GRAY = (60, 60, 60)
TEXT_COLOR = (33, 33, 33)

def create_app_icon():
    """Create 512x512 app icon with PDF compression theme"""
    size = 512
    img = Image.new('RGBA', (size, size), (255, 255, 255, 0))
    draw = ImageDraw.Draw(img)
    
    # Create circular background
    margin = 40
    circle_bbox = [margin, margin, size-margin, size-margin]
    draw.ellipse(circle_bbox, fill=PRIMARY_COLOR)
    
    # Draw document/PDF shape in the center
    doc_width = 180
    doc_height = 240
    doc_x = (size - doc_width) // 2
    doc_y = (size - doc_height) // 2 - 20
    
    # Document background (white)
    doc_bbox = [doc_x, doc_y, doc_x + doc_width, doc_y + doc_height]
    draw.rectangle(doc_bbox, fill=WHITE, outline=DARK_GRAY, width=4)
    
    # Document fold in top-right corner
    fold_size = 40
    fold_points = [
        (doc_x + doc_width - fold_size, doc_y),
        (doc_x + doc_width, doc_y + fold_size),
        (doc_x + doc_width, doc_y)
    ]
    draw.polygon(fold_points, fill=LIGHT_GRAY)
    draw.line([fold_points[0], fold_points[1]], fill=DARK_GRAY, width=4)
    
    # Draw text lines on document
    line_x = doc_x + 25
    line_width = doc_width - 50
    for i in range(4):
        line_y = doc_y + 60 + i * 25
        draw.rectangle([line_x, line_y, line_x + line_width, line_y + 8], 
                      fill=LIGHT_GRAY)
    
    # Draw compression arrows (downward pointing)
    arrow_y = doc_y + doc_height + 30
    arrow_x = size // 2
    
    # Double arrow for compression effect
    for offset in [-30, 30]:
        # Arrow shaft
        draw.rectangle([arrow_x + offset - 8, arrow_y, 
                       arrow_x + offset + 8, arrow_y + 50],
                      fill=ACCENT_COLOR)
        # Arrow head
        arrow_points = [
            (arrow_x + offset - 25, arrow_y + 50),
            (arrow_x + offset, arrow_y + 75),
            (arrow_x + offset + 25, arrow_y + 50)
        ]
        draw.polygon(arrow_points, fill=ACCENT_COLOR)
    
    # Save icon
    img.save('/home/claude/pdf_compressor_lite/assets/icon/app_icon.png', 'PNG')
    print("✓ App icon created (512x512)")
    
    # Create foreground version for adaptive icon
    img.save('/home/claude/pdf_compressor_lite/assets/icon/app_icon_foreground.png', 'PNG')
    print("✓ App icon foreground created")


def create_feature_graphic():
    """Create 1024x500 feature graphic for Google Play"""
    width = 1024
    height = 500
    img = Image.new('RGB', (width, height), PRIMARY_COLOR)
    draw = ImageDraw.Draw(img)
    
    # Create gradient-like effect with rectangles
    for i in range(height):
        alpha = i / height
        r = int(PRIMARY_COLOR[0] + (DARK_BLUE[0] - PRIMARY_COLOR[0]) * alpha)
        g = int(PRIMARY_COLOR[1] + (DARK_BLUE[1] - PRIMARY_COLOR[1]) * alpha)
        b = int(PRIMARY_COLOR[2] + (DARK_BLUE[2] - PRIMARY_COLOR[2]) * alpha)
        draw.rectangle([0, i, width, i+1], fill=(r, g, b))
    
    # Load and resize app icon
    try:
        icon = Image.open('/home/claude/pdf_compressor_lite/assets/icon/app_icon.png')
        icon = icon.resize((200, 200), Image.Resampling.LANCZOS)
        
        # Paste icon on left side
        icon_x = 80
        icon_y = (height - 200) // 2
        
        # Create a white circle background for the icon
        circle_bg = Image.new('RGBA', (220, 220), (255, 255, 255, 0))
        circle_draw = ImageDraw.Draw(circle_bg)
        circle_draw.ellipse([0, 0, 220, 220], fill=WHITE)
        
        # Paste circle and icon
        img.paste(circle_bg, (icon_x - 10, icon_y - 10), circle_bg)
        img.paste(icon, (icon_x, icon_y), icon)
    except:
        pass
    
    # Add text using default font (will be basic but functional)
    text_x = 320
    
    # Title
    try:
        # Try to use a larger font size
        font_large = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 72)
        font_medium = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 36)
    except:
        font_large = ImageFont.load_default()
        font_medium = ImageFont.load_default()
    
    # Draw title
    draw.text((text_x, 140), "PDF Compressor Lite", fill=WHITE, font=font_large)
    
    # Draw tagline
    draw.text((text_x, 250), "Compress PDFs in Seconds", fill=ACCENT_COLOR, font=font_medium)
    
    # Add decorative element - compression indicator
    indicator_x = text_x
    indicator_y = 340
    draw.text((indicator_x, indicator_y), "📄 → 📦  Save up to 90% space!", 
             fill=WHITE, font=font_medium)
    
    img.save('/home/claude/pdf_compressor_lite/assets/feature_graphic.png', 'PNG')
    print("✓ Feature graphic created (1024x500)")


def create_screenshot_mockup(filename, title, subtitle, content_type):
    """Create a mockup screenshot"""
    width = 1080
    height = 1920
    img = Image.new('RGB', (width, height), WHITE)
    draw = ImageDraw.Draw(img)
    
    # Status bar at top
    draw.rectangle([0, 0, width, 80], fill=PRIMARY_COLOR)
    
    # App bar
    draw.rectangle([0, 80, width, 230], fill=PRIMARY_COLOR)
    try:
        font_title = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 48)
        font_body = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 36)
        font_small = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 28)
    except:
        font_title = ImageFont.load_default()
        font_body = ImageFont.load_default()
        font_small = ImageFont.load_default()
    
    draw.text((60, 140), title, fill=WHITE, font=font_title)
    
    # Content area
    content_y = 280
    
    if content_type == 'home':
        # Free compressions counter
        counter_y = content_y + 80
        draw.rectangle([140, counter_y, width-140, counter_y + 200], 
                      fill=LIGHT_GRAY, outline=PRIMARY_COLOR, width=4)
        draw.text((width//2 - 150, counter_y + 50), "Free Compressions", 
                 fill=TEXT_COLOR, font=font_body)
        draw.text((width//2 - 50, counter_y + 110), "5/5", 
                 fill=PRIMARY_COLOR, font=font_title)
        
        # Select PDF button
        button_y = counter_y + 280
        draw.rectangle([140, button_y, width-140, button_y + 140],
                      fill=PRIMARY_COLOR)
        draw.text((width//2 - 130, button_y + 48), "Select PDF File",
                 fill=WHITE, font=font_body)
        
        # Info text
        info_y = button_y + 200
        draw.text((width//2 - 280, info_y), 
                 "Compress PDFs quickly and securely",
                 fill=DARK_GRAY, font=font_small)
        draw.text((width//2 - 200, info_y + 50),
                 "All processing done on device",
                 fill=DARK_GRAY, font=font_small)
    
    elif content_type == 'options':
        # Three compression levels
        option_height = 240
        for i, (level, desc, percent) in enumerate([
            ("Low", "Minimal compression", "~30%"),
            ("Medium", "Balanced quality", "~50%"),
            ("High", "Maximum compression", "~70%")
        ]):
            y = content_y + 60 + i * (option_height + 40)
            
            # Option card
            draw.rectangle([80, y, width-80, y + option_height],
                          fill=LIGHT_GRAY, outline=PRIMARY_COLOR, width=3)
            
            # Level name
            draw.text((120, y + 40), level, fill=PRIMARY_COLOR, font=font_title)
            
            # Description
            draw.text((120, y + 110), desc, fill=TEXT_COLOR, font=font_body)
            
            # Percentage
            draw.text((120, y + 165), f"Size reduction: {percent}",
                     fill=DARK_GRAY, font=font_small)
    
    elif content_type == 'progress':
        # Progress bar
        progress_y = content_y + 200
        
        # Title
        draw.text((width//2 - 180, progress_y - 100),
                 "Compressing PDF...",
                 fill=TEXT_COLOR, font=font_title)
        
        # Progress bar background
        bar_width = 800
        bar_height = 60
        bar_x = (width - bar_width) // 2
        draw.rectangle([bar_x, progress_y, bar_x + bar_width, progress_y + bar_height],
                      fill=LIGHT_GRAY, outline=DARK_GRAY, width=3)
        
        # Progress fill (65%)
        fill_width = int(bar_width * 0.65)
        draw.rectangle([bar_x, progress_y, bar_x + fill_width, progress_y + bar_height],
                      fill=PRIMARY_COLOR)
        
        # Percentage text
        draw.text((width//2 - 60, progress_y + 120),
                 "65%",
                 fill=PRIMARY_COLOR, font=font_title)
        
        # Info text
        draw.text((width//2 - 180, progress_y + 240),
                 "Processing on your device",
                 fill=DARK_GRAY, font=font_small)
    
    elif content_type == 'results':
        # Results card
        card_y = content_y + 100
        card_height = 600
        
        draw.rectangle([80, card_y, width-80, card_y + card_height],
                      fill=LIGHT_GRAY, outline=PRIMARY_COLOR, width=4)
        
        # Success message
        draw.text((width//2 - 220, card_y + 50),
                 "✓ Compression Complete!",
                 fill=PRIMARY_COLOR, font=font_title)
        
        # Original size
        draw.text((140, card_y + 160),
                 "Original Size:",
                 fill=TEXT_COLOR, font=font_body)
        draw.text((width - 300, card_y + 160),
                 "5.2 MB",
                 fill=TEXT_COLOR, font=font_body)
        
        # Compressed size
        draw.text((140, card_y + 250),
                 "Compressed Size:",
                 fill=TEXT_COLOR, font=font_body)
        draw.text((width - 300, card_y + 250),
                 "1.8 MB",
                 fill=PRIMARY_COLOR, font=font_body)
        
        # Percentage saved
        draw.text((140, card_y + 340),
                 "Space Saved:",
                 fill=TEXT_COLOR, font=font_body)
        draw.text((width - 300, card_y + 340),
                 "65%",
                 fill=ACCENT_COLOR, font=font_title)
        
        # Share button
        button_y = card_y + 470
        draw.rectangle([140, button_y, width-140, button_y + 100],
                      fill=PRIMARY_COLOR)
        draw.text((width//2 - 100, button_y + 30),
                 "Share PDF",
                 fill=WHITE, font=font_body)
    
    elif content_type == 'history':
        # History list items
        item_height = 180
        for i in range(4):
            y = content_y + 60 + i * (item_height + 30)
            
            draw.rectangle([80, y, width-80, y + item_height],
                          fill=LIGHT_GRAY)
            
            # File name
            draw.text((120, y + 30),
                     f"document_{i+1}.pdf",
                     fill=TEXT_COLOR, font=font_body)
            
            # Details
            draw.text((120, y + 85),
                     f"3.5 MB → 1.2 MB (66% saved)",
                     fill=DARK_GRAY, font=font_small)
            
            # Date
            draw.text((120, y + 130),
                     f"Feb {8-i}, 2026",
                     fill=DARK_GRAY, font=font_small)
    
    img.save(f'/home/claude/pdf_compressor_lite/assets/screenshots/{filename}', 'PNG')
    print(f"✓ Screenshot created: {filename}")


def main():
    """Generate all assets"""
    print("\n🎨 Generating Assets for PDF Compressor Lite\n")
    print("=" * 50)
    
    # Create app icon
    create_app_icon()
    
    # Create feature graphic
    create_feature_graphic()
    
    # Create screenshots
    screenshots = [
        ('home_screen.png', 'PDF Compressor', '', 'home'),
        ('compression_options.png', 'Choose Quality', '', 'options'),
        ('progress.png', 'Compressing', '', 'progress'),
        ('results.png', 'Results', '', 'results'),
        ('history.png', 'History', '', 'history'),
    ]
    
    print("\nCreating screenshots...")
    for filename, title, subtitle, content_type in screenshots:
        create_screenshot_mockup(filename, title, subtitle, content_type)
    
    print("\n" + "=" * 50)
    print("\n✅ All assets created successfully!\n")
    print("Assets location: /home/claude/pdf_compressor_lite/assets/")
    print("\nNext steps:")
    print("1. Review the generated assets")
    print("2. Add flutter_launcher_icons to pubspec.yaml")
    print("3. Run: flutter pub run flutter_launcher_icons")
    print("4. Test the app icon on a device")
    print("\n")


if __name__ == '__main__':
    main()
