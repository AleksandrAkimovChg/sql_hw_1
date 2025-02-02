-- task 01
do $$
	declare
		result_row record;
		person varchar := 'person_';
		company varchar := 'company_';
		product varchar;
		table_name varchar;
		query1 varchar;
		query2 varchar;
	begin
		<<create_table>>
		for result_row in (select distinct product_type, is_company from bid) loop
			product := result_row.product_type;
			if result_row.is_company = false then
				table_name := person || product;
				execute 'create table if not exists '
					|| table_name
					|| ' (id serial primary key,
					client_name varchar(100),
					amount numeric(12,2))';
			elsif result_row.is_company = true then
				table_name := company || product;
				execute 'create table if not exists '
					|| table_name
					|| ' (id serial primary key,
					client_name varchar(100),
					amount numeric(12,2))';
			end if;
		end loop create_table;
		<<fill_table>>
		for result_row in (select distinct product_type, is_company from bid) loop
			product := result_row.product_type;
			if result_row.is_company = false then
				table_name := person || product;
				execute 'insert into '
				|| table_name
				|| ' (client_name, amount) select client_name, amount from bid where is_company = false and product_type = '
				|| quote_literal(product);
			end if;
			if result_row.is_company = true then
				table_name := company || product;
				execute 'insert into '
				|| table_name
				|| ' (client_name, amount) select client_name, amount from bid where is_company = true and product_type = '
				|| quote_literal(product);
			end if;
		end loop fill_table;
	end;
$$

-- task 02
do $$
	declare
		credit_rate numeric(10, 1) := 0.1;
		additive numeric(10, 2) := 0.05;
		days_365 int := 365;
	begin
		execute 'create table if not exists credit_percent (id serial primary key, client_name varchar(100), amount numeric(12,2))';
		execute 'insert into credit_percent (client_name, amount) '
		|| 'select client_name, cast((amount * $1 / $2) as numeric(10, 2)) from company_credit'
			using credit_rate, days_365;
		execute 'insert into credit_percent (client_name, amount) '
		|| 'select client_name, cast((amount * ($1 + $2) / $3) as numeric(10, 2)) as amount from person_credit'
			using credit_rate, additive, days_365;
	end;
$$

-- task 03
do $$
	begin
		execute 'create view manager_bid as (
					select *
					from bid
					where is_company = true
				)';
	end;
$$