questions =
[
  { body: 'Перша серія серіалу, присвяченого Ганнібалу Лектеру, називається французьким словом. Яким?', answers: ['аперетив', 'aperitive'], outdated: false, round: 1 },
  { body: 'Шон Елліс, пояснюючи свою дружбу з собаками, пише, що його дитинство пройшло на фермі, в місцевості, де НИМИ називалися ті, хто жив на відстані одного дня шляху. Назвіть ЇХ.', answers: ['сусіди', 'соседи'], outdated: false, round: 2 },
  { body: 'У статті, присвяченій упаковці речей в дорогу, згадується гра. Яка?', answers: ['тетріс', 'тетрис', 'tetris'], outdated: false, round: 3 },
  { body: "Які ім'я та прізвище згадав Майкл Мосс, описуючи враження від свого відвідування заводу 'Nestlé'?", answers: ['Віллі Вонка', 'Вилли Вонка', 'Willie Wonka'], outdated: false, round: 4 },
  { body: 'Те, для чого китайці використовують слово "Шань-шуй" - "гора і вода", ми називаємо французьким словом. Яким?', answers: ['пейзаж'], outdated: false, round: 5 }
]
Question.delete_all
questions.each do |question|
  Question.new(question).upsert
end
