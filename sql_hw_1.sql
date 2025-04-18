--1. Создать таблицу с факультетами: id, имя факультета, стоимость обучения
create table faculty (
                        id int primary key,
						name varchar(50),
						coast numeric(10, 2)
						);

--2. Создать таблицу с курсами: id, номер курса, id факультета
create table course (
						id int primary key,
						number int,
						faculty_id int references faculty(id)
						);

--3. Создать таблицу с учениками: id, имя, фамилия, отчество, бюджетник/частник, id курса
create table student (
						id int primary key,
						first_name varchar(50),
						last_name varchar(50),
						middle_name varchar(50),
						is_budget boolean,
						course_id int references course(id)
						);

-- Часть 2. Заполнение данными:
-- 1. Создать два факультета: Инженерный (30 000 за курс) , Экономический (49 000 за курс)
insert into faculty values(1, 'Инженерный', 30000);
insert into faculty values(2, 'Экономический', 49000);

-- 2. Создать 1 курс на Инженерном факультете: 1 курс
insert into course values(
						1, 
						1, 
							(select id 
							from faculty 
							where name like('Инженерный')
							)
						);

-- 3. Создать 2 курса на экономическом факультете: 1, 4 курс
insert into course values(
						2, 
						1, 
							(select id 
							from faculty 
							where name like('Экономический')
							)
						);
insert into course values(
						3, 
						4, 
							(select id 
							from faculty 
							where name like('Экономический')
							)
						);

-- 4. Создать 5 учеников:
-- Петров Петр Петрович, 1 курс инженерного факультета, бюджетник
insert into student values(
							1, 
							'Петр',
							'Петров',
							'Петрович',
							true,
							(select id 
								from course 
								where number = 1 and faculty_id = (select id 
														from faculty
														where name like('Инженерный')
													)
							)
						);
-- Иванов Иван Иваныч, 1 курс инженерного факультета, частник
insert into student values(
							2, 
							'Иван',							
							'Иванов',
							'Иваныч',
							false,
							(select id 
								from course 
								where number = 1 and faculty_id = (select id 
														from faculty
														where name like('Инженерный')
													)
							)
						);
-- Михно Сергей Иваныч, 4 курс экономического факультета, бюджетник
insert into student values(
							3, 
							'Сергей',
							'Михно',
							'Иваныч',
							true,
							(select id 
								from course 
								where number = 4 and faculty_id = (select id 
														from faculty
														where name like('Экономический')
													)
							)
						);
-- Стоцкая Ирина Юрьевна, 4 курс экономического факультета, частник
insert into student values(
							4, 
							'Ирина',
							'Стоцкая',
							'Юрьевна',
							false,
							(select id 
								from course 
								where number = 4 and faculty_id = (select id 
														from faculty
														where name like('Экономический')
													)
							)
						);
-- Младич Настасья (без отчества), 1 курс экономического факультета, частник
insert into student values(
							5, 
							'Настасья',
							'Младич',
							null,
							false,
							(select id 
								from course 
								where number = 1 and faculty_id = (select id 
														from faculty
														where name like('Экономический')
													)
                           )
                        );

-- Часть 3. Выборка данных. Необходимо написать запросы, которые выведут на экран:
-- 1. Вывести всех студентов, кто платит больше 30_000.
select student.*, course.faculty_id, faculty.name, faculty.coast
from student
left join course on student.course_id = course.id
left join faculty on course.faculty_id = faculty.id
where student.is_budget = false and faculty.coast > 30000;

-- 2. Перевести всех студентов Петровых на 1 курс экономического факультета.
update student
set course_id = (select course.id
				from course
				left join faculty on course.faculty_id = faculty.id
				where course.number = 1 and faculty.name = 'Экономический')
where student.last_name = 'Петров' or student.last_name = 'Петрова';

-- 3. Вывести всех студентов без отчества или фамилии.
select *
from student
where middle_name is null or last_name is null;

-- 4. Вывести всех студентов содержащих в фамилии или в имени или в отчестве "ван".
--(пример name like '%Петр%' - найдет всех Петров, Петровичей, Петровых)
select *
from student
where last_name like '%ван%' or first_name like '%ван%' or middle_name like '%ван%';

-- 5. Удалить все записи из всех таблиц.
delete from student;
delete from course;
delete from faculty;
