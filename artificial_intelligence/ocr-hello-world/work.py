from PIL import Image
import pytesseract
import re
import argparse

def ocr_image(image_path):
    image = Image.open(image_path)
    text = pytesseract.image_to_string(image, lang='jpn')
    return text

def extract_info(text):
    product_pattern = r'([A-Za-z0-9\s]+)'  # 商品名パターン
    price_pattern = r'(\d+)'  # 金額パターン

    product = re.findall(product_pattern, text)
    price = re.findall(price_pattern, text)

    return product, price


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('arg1', type=str, help='required')
    args = ap.parse_args();

    text = ocr_image(args.arg1)
    # product, price = extract_info(text)
    print(text)
    return text


if __name__ == "__main__":
    main()