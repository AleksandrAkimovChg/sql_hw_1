-- task 01
do $$
	declare
		result_row record;
		person varchar := 'person_';
		company varchar := 'company_';
		product varchar;
		table_name varchar;
	begin
		for result_row in (select distinct product_type, is_company from bid) loop
			product := result_row.product_type;
			if result_row.is_company = false then
				table_name := person || product;
			elsif result_row.is_company = true then
				table_name := company || product;
			end if;
			execute 'create table if not exists '
				|| table_name
				|| ' (id serial primary key,
				client_name varchar(100),
				amount numeric(12,2))';
			execute 'insert into '
				|| table_name
				|| ' (client_name, amount) select
				client_name, amount from bid
				where is_company = $1 and product_type = $2'
				using result_row.is_company, product;
		end loop;
	end;
$$;

-- task 02
do $$
	declare
		credit_rate numeric(10, 1) := 0.1;
		additive numeric(10, 2) := 0.05;
		days_365 int := 365;
	begin
		create table if not exists credit_percent (id serial primary key, client_name varchar(100), amount numeric(12,2));
		execute 'insert into credit_percent (client_name, amount)
			select client_name, round((amount * $1 / $2), 2) as amount
			from company_credit'
			using credit_rate, days_365;
		execute 'insert into credit_percent (client_name, amount)
			select client_name, round((amount * ($1 + $2) / $3), 2) as amount
			from person_credit'
			using credit_rate, additive, days_365;
		raise notice 'Общая сумма начисленных процентов в таблице credit_percent = %',
			(select sum(amount) from credit_percent);
	end;
$$;


-- task 03
create or replace view manager_bid as (
    select *
	from bid
	where is_company = true);