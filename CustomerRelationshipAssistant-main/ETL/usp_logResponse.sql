
create table sales (
    id serial not null primary key,
    info jsonb not null
)
insert into sales values (1, '{name: "Alice", paying: true, tags: ["admin"]}');
update sales set info = '{name: "Bob", paying: false, tags: []}';
update sales set info = info || '{"country": "Canada"}';
update sales set info = info - 'country';

