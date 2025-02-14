-- Закрытая вечеринка.
-- 1. Создать таблицу party_guest: name, email, (id само собой),
-- пришел или нет (по умолчанию стоит нет).
-- Name, email не может быть null и быть пустым. Email уникален.

create table party_guest (
	id bigserial primary key,
	name varchar(50) not null check (length(trim(name)) > 0),
	email varchar(50) not null unique check (length(trim(email)) > 0),
	is_come boolean not null default false);

-- 2. Создать пользователя manager.
-- Он может заносить данные в таблицу с гостями, а так же смотреть список гостей.
-- + (дать права на работу со схемой public)

create user manager with password 'manager';
grant usage on schema public to manager;
grant select, insert on table party_guest to manager;

-- 3. Создать view party_guest_name. Должны быть только имена гостей.

create or replace view party_guest_name as (select name from party_guest);

-- 4. Создать пользователя guard. Он может только смотреть только view party_guest_name.

create user guard with password 'guard';
grant select on table party_guest_name to guard;

-- 5. Переключиться на пользователя manager.
-- Создать под этой ролью записи в таблице party_guest (имя, email):
-- --Charles charles_ny@yahoo.com
-- --Charles mix_tape_charles@google.com
-- --Teona miss_teona_99@yahoo.com

set role manager;
set role postgres;
GRANT USAGE ON SEQUENCE party_guest_id_seq TO manager; --иначе была ошибка по доступу к секвенсу
set role manager;
insert into party_guest (name, email) values
	('Charles', 'charles_ny@yahoo.com'),
	('Charles', 'mix_tape_charles@google.com'),
	('Teona', 'miss_teona_99@yahoo.com');

-- 6. Переключиться на роль guard и посмотреть имена.
-- Проверить, что guard не имеет доступа к таблице party_guest.
set role guard;
select * from party_guest_name;
--select * from party_guest;

-- 7. Перейти в роль postgres

set role postgres;

-- 8. Создать процедуру party_end, которая будет закидывать в черный список всех тех людей,
-- которые записались на вечеринку, но не пришли:
-- 8.1. Создает таблицу black_list (id, email) если она не существует.
-- 8.2. Записывает в black_list тех, кто не пришел на вечеринку.
-- 8.3. Очищает таблицу party_guest.

create or replace procedure party_end()
language plpgsql
as $$
	begin
		create table if not exists black_list
			(id bigserial primary key,
			name varchar(50) not null,
			email varchar(50) not null unique);
		insert into black_list (name, email)
			select name, email
			from party_guest
			where is_come = false;
		delete from party_guest;
	end;
$$;

-- 9. Создать функцию записи на вечеринку register_to_party:
-- на вход будет принимать name, email. Функция будет:
-- 9.1 Проверяет есть ли таблица black_list (см комментарий), если есть, то:
-- 9.1.1. Проверять есть ли такой человек в black_list по email.
-- Если такой человек есть, то функция вернет false
-- 9.2. Если человека нет в черном списке
--	или таблицы black_list не существует,
-- то вставить запись в таблицу party_guest name и email и вернуть true.

create or replace function register_to_party(_name varchar, _email varchar)
returns boolean
language plpgsql
as $$
	declare
		black_list_table_exists boolean := (select to_regclass('public.black_list') is not null);
	begin
		insert into party_guest (name, email) values (_name, _email);
		if black_list_table_exists then
		    if exists (select 1 from black_list where lower(email) = lower(_email)) then
		        rollback;
		        return false;
		    end if;
		end if;
		return true;
	end;
$$;


-- 10. Зарегистрировать Petr, korol_party@yandex.ru на вечеринку с помощью функции.

select register_to_party('Petr', 'korol_party@yandex.ru');

-- 11. На вечеринку пришли гости с
-- email - mix_tape_charles@google.com, miss_teona_99@yahoo.com.
-- Поменять статус у них на "пришел"

update party_guest
set is_come = true
where lower(email) = lower('mix_tape_charles@google.com');

update party_guest
set is_come = true
where lower(email) = lower('miss_teona_99@yahoo.com');

-- 12. Запустить процедуру party_end.

call party_end();

-- Комментарий:
-- Для получения информации, есть ли такая таблица в схеме,
-- можно воспользоваться SELECT to_regclass('[имя схемы].[имя таблицы]') is not null;
