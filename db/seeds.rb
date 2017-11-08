questions = [
              { body: "Тема: Довкола спорту. Питання: На соціальній рекламі поруч зображені баскетболіст з мячем у руці та людина із сигаретою. Підпис закликає обох героїв *РОБИТИ ЦЕ*.",
                answers: ['кидати', 'бросать', 'кидать', 'кинути'], for_tournament: false, round: nil },
              { body: "Тема: Щити. Питання: *ЦЕЙ ЩИТ* дав назву щотижневому американському журналу, присвяченому музичній індустрії. До речі, автор питання швидко і недорого напише потрібну кількість тем 'своєї гри' для чемпіонату вашого міста або вузу.",
                answers: ['бігборд', 'біг-борд', 'білборд', 'билборд', 'рекламний щит', 'рекламный щит'], 
                for_tournament: false, round: nil },
              { body: "Тема: Фінансова тема. Питання: Жадібний Біллі не бажав платити *ЇХ* ні за цукерки, ні за астри.",
                answers: ['піастри', 'пьястри', 'пиастры'], for_tournament: false, round: nil },
              { body: "Тема: Музика та музиканти. Питання: Згідно з дослідженнями вчених, в більшості своїй *ВОНИ* глухуваті на ліве вухо.",
                answers: ['скрипалі', 'скрипачі', 'скрипаль', 'скрипач', 'скрипачь'], for_tournament: false, round: nil },
              { body: "Тема: Божевільна тема. Питання: Батько Карла VI Божевільного носив *ЦЕ ПРІЗВИСЬКО*, не дарма ж кажуть, що природа на дітях відпочиває.",
                answers: ['мудрий', 'розумний', 'мудрый'], for_tournament: false, round: nil },
              { body: "Тема: Закордонний шоубіз. Питання: Журнал 'Forbes' у 2012 році назвав ЙОГО третім серед найвпливовіших знаменитостей у світі, що не завадило пресі в його рідній Канаді відчитати ЙОГО як хлопчиська за неналежний вигляд на візиті до прем'єр-міністра.",
                answers: ['бібер', 'джастін бібер', 'бібєр', 'джастін бібєр', 'bieber', 'justin bieber'] },
              { body: "Тема: Сиджу за ґратами. Питання: На ЦЬОМУ ОСТРОВІ немає жодної колонії пеліканів, та й колонії для особливо небезпечних злочинців вже давно немає: зараз вона перетворилася в музей.",
                answers: ['алькатрас', 'алкатрас', 'alcatraz'] },
              { body: "Тема: Вигадані землі. Питання: Відомий письменник придумав ЦЕЙ вигаданий КОНТИНЕНТ, буквально переклавши назву населеного людьми міфічного світу, що знаходиться посередині між небесами і пеклом.",
                answers: ["середзем'я", 'средиземье', 'middle-earth', 'середземя'] },
              { body: "Тема: Вигадані землі. Питання: Борис Заходер переклав ЦЮ НАЗВУ як 'Гдетотам'.",
                answers: ['неверленд', 'neverland'] },
              { body: "Тема: Погана тема. Питання: Погано спроектована, слабо структурована, заплутана і важка для розуміння програма називається терміном, що містить ЦЕЙ ПРОДУКТ ХАРЧУВАННЯ.",
                answers: ['спагеті', 'спагетті', 'spagetti', 'spaghetti', 'spaghetti code', 'spagetti code', 'спагеті код', 'спагетти код', 'спагетті код'] },
              { body: "Тема: Праски. Питання: Міська легенда говорить, що архітектор нью-йоркського хмарочоса 'Праска' покінчив життя самогубством, коли перед самим розрізанням стрічки згадав, що забув спроектувати в будівлі ЇХ. Міг би потерпіти і потім вирішити якось цю проблему.",
                answers: ['туалети', 'туалет', 'туалєт', 'туалєти'], for_tournament: true, round: 1 },
              { body: "Тема: Золота тема. Питання: В українському варіанті озвучки герой Енді Сьоркіса називає ЙОГО 'моє золотце'.",
                answers: ['перстень всесилля', 'перстень всевладдя', 'кольцо всевластия', 'кільце всесилля', 'кільце всевладдя', 'кольцо всесилия', 'кольцо всесилля', 'кольцо всевладдя', 'кольцо всевластя'], for_tournament: true, round: 2 },
              { body: "Тема: Кіно та наркотики. Питання: У фільмі 'Реквієм за мрією' герой перестав колоти собі героїн лише втративши ЇЇ.",
                answers: ['hand', 'рука', 'руку'], for_tournament: true, round: 3 },
              { body: "Тема: Пісенна тема. Питання: У вірші ЖЖ-юзера dimegga герой наспівує ЦЮ знамениту ПІСНЮ, занурюючи в воду пакетик чаю 'Lipton yellow label'.",
                answers: ['жовта субмарина', 'yellow submarine', 'yelow submarine', 'yellow submarin', 'желтая субмарина', 'yelow submarin', 'yelow submarine', 'жовту субмарину', 'жовта супмарина', 'жовту супмарину'], for_tournament: true, round: 4 },
              { body: "Тема: Горіхи. Питання: Вважається, що ЙОГО лікувальні властивості обумовлені зовнішньою схожістю з людським мозком.",
                answers: ['грецький горіх', 'грецького горіха', 'грецького горіху', 'греческий орех', 'греческого ореха'], for_tournament: true, round: 5 },
            ]

questions.each do |question|
  Question.new(question).upsert
end
