import time
from requests_html import HTMLSession


def is_updated(result_tr_list, newest_result_tr_list):
    '''
    結果の更新があったかを判定する関数
    pram: result_tr_list: List[<Element 'tr' >] １状態前の結果リスト
    pram: newest_result_tr_list: List[<Element 'tr' >] 現在の状態の結果リスト
    res: bool
    '''
    return len(result_tr_list) != len(newest_result_tr_list)


def get_and_print_newest_result(result_tr_list):
    session = HTMLSession()
    # url = 'https://baseball.yahoo.co.jp/npb/game/2021005352/score'  # 最新の情報
    url = 'https://baseball.yahoo.co.jp/npb/game/2021005340/score?index=0920300'  # 固定の情報
    r = session.get(url)

    r_html = r.html
    pitcher = r_html.xpath('//*[@id="gm_rslt"]/tbody/tr/td[1]')[0].text
    batter = r_html.xpath('//*[@id="gm_rslt"]/tbody/tr/td[3]')[0].text
    newest_result_tr_list = r_html.xpath('//*[@id="pitchesDetail"]/section[2]/table[3]/tbody/tr')
    if is_updated(result_tr_list, newest_result_tr_list):
        print(f'{pitcher} v.s. {batter}')
        print(newest_result_tr_list[-1].text.split('\n')[-1][1:-1])
        print()
        result_tr_list = newest_result_tr_list
    return newest_result_tr_list

def main():
    result_tr_list = []
    INTERVAL = 10
    while True:
        result_tr_list = get_and_print_newest_result(result_tr_list)
        time.sleep(INTERVAL)


if __name__ == '__main__':
    main()
