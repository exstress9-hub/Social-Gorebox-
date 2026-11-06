import 'package:flutter/material.dart';

final lang = ValueNotifier<String>('tr');
String t(String k) => (lang.value == 'ru' ? _ru : _tr)[k] ?? k;

class Cat {
  final String id;
  final IconData icon;
  final List<String> games;
  const Cat(this.id, this.icon, this.games);
}

const cats = [
  Cat('cat1', Icons.visibility_off, ['impostor', 'spy', 'werewolf']),
  Cat('cat2', Icons.theater_comedy, ['taboo', 'whoami', 'charades', 'draw']),
  Cat('cat3', Icons.bolt, ['buzzer', 'quiz', 'tf']),
  Cat('cat4', Icons.forum, ['tod', 'never', 'likely']),
];

const playable = {'impostor', 'spy', 'buzzer', 'taboo', 'tod'};

const trWords = <String>[
  'Elma', 'Deve', 'Halı', 'Çay', 'Okul', 'Doktor', 'Deniz', 'Kervan',
  'Pilav', 'Futbol', 'Ay', 'Saat', 'Gözlük', 'Piyano', 'Helikopter', 'Orman', 'Çikolata', 'Gitar'
];

const ruWords = <String>[
  'Яблоко', 'Верблюд', 'Ковёр', 'Чай', 'Школа', 'Врач', 'Море', 'Караван',
  'Плов', 'Футбол', 'Луна', 'Часы', 'Очки', 'Пианино', 'Вертолёт', 'Лес', 'Шоколад', 'Гитара'
];

class SpyLocationData {
  final String nameTr;
  final String nameRu;
  final List<String> rolesTr;
  final List<String> rolesRu;
  const SpyLocationData(this.nameTr, this.nameRu, this.rolesTr, this.rolesRu);
}

const spyLocations = <SpyLocationData>[
  SpyLocationData(
    'Yolcu Uçağı', 'Самолёт',
    ['Pilot', 'Hostes', 'Yolcu', 'Hava Polisi', 'Uçak Mühendisi'],
    ['Пилот', 'Стюардесса', 'Пассажир', 'Маршал', 'Инженер']
  ),
  SpyLocationData(
    'Hastane', 'Больница',
    ['Başhekim', 'Cerrah', 'Hemşire', 'Hasta', 'Güvenlik Görevlisi'],
    ['Главврач', 'Хирург', 'Медсестра', 'Пациент', 'Охранник']
  ),
  SpyLocationData(
    'Denizaltı', 'Подводная лодка',
    ['Kaptan', 'Sonar Uzmanı', 'Makinist', 'Aşçı', 'Torpido Nişancısı'],
    ['Капитан', 'Сонарщик', 'Механик', 'Повар', 'Торпедист']
  ),
  SpyLocationData(
    'Korsan Gemisi', 'Пиратский корабль',
    ['Korsan Kaptanı', 'Dümenci', 'Gözcü', 'Tutsak', 'Tayfa'],
    ['Капитан', 'Рулевой', 'Вперёдсмотрящий', 'Пленник', 'Матрос']
  ),
  SpyLocationData(
    'Uzay İstasyonu', 'Космическая станция',
    ['İstasyon Komutanı', 'Astronot', 'Biyolog', 'Uzay Turisti', 'Robot Mühendisi'],
    ['Командир', 'Астронавт', 'Учёный', 'Турист', 'Инженер']
  ),
];

class TabooItem {
  final String wordTr, wordRu;
  final List<String> forbiddenTr, forbiddenRu;
  const TabooItem(this.wordTr, this.wordRu, this.forbiddenTr, this.forbiddenRu);
}

const tabooDeck = <TabooItem>[
  TabooItem('FUTBOL', 'ФУТБОЛ', ['Top', 'Gol', 'Maç', 'Saha', 'Hakem'], ['Мяч', 'Гол', 'Матч', 'Поле', 'Судья']),
  TabooItem('DOKTOR', 'ВРАЧ', ['Hastane', 'İlaç', 'Hasta', 'Stetoskop', 'Muayene'], ['Больница', 'Лекарство', 'Пациент', 'Стетоскоп', 'Осмотр']),
  TabooItem('KAHVE', 'КОФЕ', ['Fincan', 'Kafein', 'Sabah', 'Sıcak', 'Çekirdek'], ['Чашка', 'Кофеин', 'Утро', 'Горячий', 'Зёрна']),
  TabooItem('SİNEMA', 'КИНО', ['Film', 'Mısır', 'Bilet', 'Salon', 'Perde'], ['Фильм', 'Попкорн', 'Билет', 'Зал', 'Экран']),
  TabooItem('GÜNEŞ', 'СОЛНЦЕ', ['Sıcak', 'Yaz', 'Işık', 'Gündüz', 'Sarı'], ['Жара', 'Лето', 'Свет', 'День', 'Жёлтый']),
];

class TodItem {
  final bool isTruth;
  final String textTr, textRu;
  const TodItem(this.isTruth, this.textTr, this.textRu);
}

const todDeck = <TodItem>[
  TodItem(true, 'Bu odadaki birinin en komik özelliğini söyle.', 'Назови самую смешную черту кого-то в этой комнате.'),
  TodItem(true, 'Telefonundaki en son arama geçmişini açıkla.', 'Что ты искал в браузере в последний раз?'),
  TodItem(true, 'En büyük korkun nedir?', 'Какой твой самый большой страх?'),
  TodItem(false, 'Gruptaki herkesi güldürecek bir hayvan taklidi yap.', 'Изобрази животное так, чтобы все рассмеялись.'),
  TodItem(false, '1 dakika boyunca sadece şarkı söyler gibi konuş.', 'Говори как оперный певец в течение 1 минуты.'),
];

const _tr = <String, String>{
  'sub': 'Hotspot ile çevrimdışı parti oyunları',
  'name': 'Adın',
  'join': 'Oyuna katıl',
  'tap': 'Oda açmak için bir oyun seç',
  'cat1': 'Gizli Roller',
  'cat2': 'Anlat ve Tahmin Et',
  'cat3': 'Hız ve Bilgi',
  'cat4': 'Sohbet ve Yakınlaşma',
  'impostor': 'Impostor',
  'werewolf': 'Werewolf',
  'spy': 'Casus Mekân',
  'charades': 'Charades',
  'whoami': 'Who Am I',
  'taboo': 'Yasak Kelime (Tabu)',
  'draw': 'Çiz Bakalım',
  'buzzer': 'Hızlı Parmak',
  'quiz': 'Bilgi Yarışı',
  'tf': 'Doğru mu Yanlış mı',
  'never': 'Hiç Yapmadım',
  'likely': 'Kim Daha Olası',
  'tod': 'Doğruluk mu Cesaret mi',
  'soon': 'Yakında',
  'players': 'Oyuncular',
  'start': 'Başlat',
  'need3': 'En az 3 oyuncu gerekli',
  'ipinfo': 'Arkadaşların «Oyuna katıl» tuşuna bassın. Bulamazsa IP: ',
  'searching': 'Yakındaki odalar aranıyor…',
  'manual': 'IP ile bağlan',
  'connect': 'Bağlan',
  'waiting': 'Host oyunu başlatınca burada görünecek',
  'hold': 'Kartı görmek için basılı tut',
  'impWord': 'SEN IMPOSTORSUN! Kelimeyi bilmiyorsun.',
  'spyWord': 'SEN CASUSSUN! Mekânı bilmiyorsun.',
  'word': 'Kelime',
  'location': 'Mekân',
  'role': 'Rolün',
  'fail': 'Bağlanılamadı',
  'back': 'Geri',
  'vote': 'Haini Oyla',
  'voteTitle': 'Kimi hain olarak oyluyorsun?',
  'voting': 'Oylama yapılıyor...',
  'voteResult': 'Oylama Sonucu',
  'impostorWas': 'Impostor oydu:',
  'innocentWas': 'Masumdu! Impostor aranızda kaldı:',
  'buzzerHit': 'BUTONA BASTI!',
  'buzzerPress': 'BASTIM!',
  'buzzerReset': 'Sıfırla',
  'truth': 'Doğruluk',
  'dare': 'Cesaret',
  'nextTask': 'Yeni Soru / Görev',
  'tabooForbidden': 'YASAKLI KELİMELER',
  'tabooCorrect': 'DOĞRU (+1)',
  'tabooSkip': 'PAS',
  'tabooViolated': 'TABU (-1)',
};

const _ru = <String, String>{
  'sub': 'Парти-игры по хотспоту без интернета',
  'name': 'Твоё имя',
  'join': 'Присоединиться',
  'tap': 'Выбери игру, чтобы открыть комнату',
  'cat1': 'Секретные роли',
  'cat2': 'Объясни и угадай',
  'cat3': 'Скорость и знания',
  'cat4': 'Общение',
  'impostor': 'Impostor',
  'werewolf': 'Werewolf',
  'spy': 'Шпион',
  'charades': 'Charades',
  'whoami': 'Who Am I',
  'taboo': 'Запретные слова',
  'draw': 'Рисуй и угадывай',
  'buzzer': 'Быстрый палец',
  'quiz': 'Викторина',
  'tf': 'Правда или ложь',
  'never': 'Я никогда не',
  'likely': 'Кто скорее всего',
  'tod': 'Правда или действие',
  'soon': 'Скоро',
  'players': 'Игроки',
  'start': 'Начать',
  'need3': 'Нужно минимум 3 игрока',
  'ipinfo': 'Пусть друзья нажмут «Присоединиться». Если не найдут, IP: ',
  'searching': 'Ищем комнаты рядом…',
  'manual': 'Подключиться по IP',
  'connect': 'Подключиться',
  'waiting': 'Ждём, пока хост начнёт игру',
  'hold': 'Зажми, чтобы увидеть карту',
  'impWord': 'ТЫ ИМПОСТОР! Ты не знаешь слово.',
  'spyWord': 'ТЫ ШПИОН! Ты не знаешь локацию.',
  'word': 'Слово',
  'location': 'Локация',
  'role': 'Твоя роль',
  'fail': 'Не удалось подключиться',
  'back': 'Назад',
  'vote': 'Голосование',
  'voteTitle': 'Кто предатель?',
  'voting': 'Идёт голосование...',
  'voteResult': 'Результат голосования',
  'impostorWas': 'Импостором был:',
  'innocentWas': 'Был невиновен! Импостор среди нас:',
  'buzzerHit': 'НАЖАЛ ПЕРВЫМ!',
  'buzzerPress': 'ЖМИ!',
  'buzzerReset': 'Сброс',
  'truth': 'Правда',
  'dare': 'Действие',
  'nextTask': 'Следующее задание',
  'tabooForbidden': 'ЗАПРЕТНЫЕ СЛОВА',
  'tabooCorrect': 'ВЕРНО (+1)',
  'tabooSkip': 'ПАС',
  'tabooViolated': 'ТАБУ (-1)',
};
