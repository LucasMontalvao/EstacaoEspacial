create database Estacao_Espacial;
------------------------------------------------------------------------------------------------------------------------------
use Estacao_Espacial;
------------------------------------------------------------------------------------------------------------------------------
create table Espaconaves(
	espaconaveId		int constraint PK_CodigoNave primary key identity(1,1),
	nome				varchar(50) not null,
	tagName				varchar(3),
	dataRegistro		datetime
);
create table TiposObjetos(
	tipoObjetoId		int constraint PK_CodigoTipoObjeto primary key identity(1,1),
	descricaoObjeto		varchar(50),
	nomeObjeto			varchar(50)
);
create table Paradas(
	paradaId			int constraint PK_CodigoParada primary key identity(1,1),
	tipoObjeto_FK		int,
	nomeParada			varchar(50)
);
create table TipoEstoque(
	tipoEstoqueId		int constraint PK_CodigoTipoEstoque primary key identity(1,1),
	descricaoEstoque	varchar(50)
);
create table Estoque(
	estoqueId			int constraint PK_CodigoEstoque primary key identity(1,1),
	paradaFK			int,
	tipoEstoqueFK		int,
	produtoFK			int,
	quantidade			int,
	unidadeMedida		varchar(50)
);
create table Produtos(
	produtoId			int constraint PK_CodigoProduto primary key identity(1,1),
	descricaoProduto	varchar(50),
	precoUnitario		float
);
create table Vendas(
	vendaId				int constraint PK_CodigoVenda primary key identity(1,1),
	paradaFK			int,
	espaconaveFK		int,
	precoTotal			float,
	dataCompra			datetime
);
create table Vendas_Produtos(
	vendas_ProdutosId	int constraint PK_CodigoVendaProduto primary key identity(1,1),
	vendaFK				int,
	produtoFK			int,
	quantidade			int,
	unidadeMedida		varchar(50)
);
------------------------------------------------------------------------------------------------------------------------------
alter table Estoque			add constraint FK_parada				foreign key(paradaFK)		references Paradas(paradaId);
alter table Estoque			add constraint FK_tipoEstoque			foreign key(tipoEstoqueFK)	references TipoEstoque(tipoEstoqueId);
alter table Estoque			add constraint FK_produto				foreign key(produtoFK)		references Produtos(produtoId);
alter table Paradas			add constraint FK_tipoObjeto			foreign key(tipoObjeto_FK)	references TiposObjetos(tipoObjetoId);	
alter table Vendas			add constraint FK_parada_Vendas			foreign key(paradaFK)		references Paradas(paradaId);
alter table Vendas			add constraint FK_espaconave_Vendas		foreign key(espaconaveFK)	references Espaconaves(espaconaveId);
alter table Vendas_Produtos add constraint FK_venda					foreign key(vendaFK)		references Vendas(vendaId);
alter table Vendas_Produtos add constraint FK_produto_Venda			foreign key(produtoFK)		references Produtos(produtoId);
------------------------------------------------------------------------------------------------------------------------------
create or alter function func_calc_precoTotal (@codigoVenda int)
	returns float
	as
	begin
		declare @precoTotal float;
		set		@precoTotal = (select sum(precoUnitario * quantidade)	from	Vendas_Produtos inner join produtos 
																		on		Produtos.produtoId = Vendas_Produtos.produtoFK
																		where	vendaFK = 1);
		return	@precoTotal;
end;

------------------------------------------------------------------------------------------------------------------------------
create or alter procedure proc_CRUD_Estoque
@opcao INT,
@estoqueId int,
@parada varchar(50),
@tipoEstoque varchar(50),
@produto varchar(50),
@quantidade int,
@UnidadeMedida varchar(50)
as
begin
	declare @codigoParada int, @codigoTipoEstoque int, @codigoProduto int;
	set @codigoParada		= (select paradaId		from Paradas		where nomeParada		like @parada);
	set @codigoTipoEstoque	= (select tipoEstoqueId	from TipoEstoque	where descricaoEstoque	like @tipoEstoque);
	set @codigoProduto		= (select produtoId		from Produtos		where descricaoProduto	like @produto);
	if		(@opcao = 1) 
			insert into Estoque(paradaFK, tipoEstoqueFK, produtoFK, quantidade, unidadeMedida)values(
												  @codigoParada,
												  @codigoTipoEstoque,
												  @codigoProduto,
												  @quantidade, 
												  @UnidadeMedida);
	else if	(@opcao = 2)
			update Estoque	set	  paradaFK		= @codigoParada,
								  tipoEstoqueFK	= @codigoTipoEstoque,
								  produtoFK		= @codigoProduto,
								  quantidade	= @quantidade,
								  unidadeMedida	= @UnidadeMedida
							where estoqueId		= @estoqueId;
	else if (@opcao = 3)
			delete from Estoque 
							where estoqueId		= @estoqueId;
end;

------------------------------------------------------------------------------------------------------------------------------
create or alter procedure proc_CRUD_Espaconave
@opcao int,
@espaconaveId int,
@nomeNave varchar(50),
@tagName varchar(3)
as
begin
	if		(@opcao = 1)
			insert into Espaconaves(nome, tagName, dataRegistro)values(
													  @nomeNave, 
													  @tagName, 
													  GETDATE());
	else if (@opcao = 2)
			update Espaconaves	set	  nome			= @nomeNave, 
									  tagName		= @tagName, 
									  dataRegistro	= GETDATE() 
								where espaconaveId	= @espaconaveId;
	else if (@opcao = 3)
			delete from Espaconaves 
								where espaconaveId	= @espaconaveId;
end;

------------------------------------------------------------------------------------------------------------------------------
create or alter procedure proc_CRUD_Paradas
@opcao int,
@paradaId int,
@nomeObjeto varchar(50),
@nomeParada varchar(50)
as
begin
	declare @tipoObjeto int;
	set @tipoObjeto = (select tipoObjetoId from TiposObjetos where nomeObjeto like @nomeObjeto);
	if		(@opcao = 1)
				insert into Paradas(nomeParada, tipoObjeto_FK)values(
													  @nomeParada,
													  @tipoObjeto);
	else if(@opcao = 2)
				update Paradas	set	  nomeParada	= @nomeParada,
									  tipoObjeto_FK	= @tipoObjeto
								where paradaId		= @paradaId;
	else if(@opcao = 3)
				delete from Paradas 
								where paradaId		= @paradaId;
end;

------------------------------------------------------------------------------------------------------------------------------
create or alter procedure proc_CRUD_Produtos
@opcao int,
@produtoId int,
@descProd varchar(50),
@precoUnit float
as
begin
	if		(@opcao = 1)
				insert into Produtos(descricaoProduto, precoUnitario)values(
														  @descProd, 
														  @precoUnit);
	else if	(@opcao = 2)
				update Produtos set   descricaoProduto	= @descProd,
									  precoUnitario		= @precoUnit
								where produtoId			= @produtoId;
	else if	(@opcao = 3)
				delete from Produtos 
								where produtoId			= @produtoId;
end;

------------------------------------------------------------------------------------------------------------------------------
create or alter procedure proc_CRUD_Vendas
@opcao int,
@vendaId int,
@parada varchar(50),
@espaconave varchar(50)
as 
begin 
	declare @codigoProduto int, @codigoParada int, @codigoNave int, @unidadeMedida varchar(50);
	set @codigoParada	= (select paradaId		from Paradas		where nomeParada		like @parada);
	set @codigoNave		= (select espaconaveId	from Espaconaves	where nome				like @espaconave);
	if		(@opcao = 1)
			insert into Vendas(paradaFK, espaconaveFK, dataCompra)values(
												   @codigoParada,
												   @codigoNave,
												   GETDATE());
	else if(@opcao = 2)
			update Vendas set	paradaFK		= (@codigoParada),
								espaconaveFK	= (@codigoNave),
								dataCompra		= GETDATE()
								where VendaId	= (@vendaId);
	else if(@opcao = 3)
			delete from Vendas_Produtos where VendaFK	= (@vendaId);
			delete from Vendas			where VendaId	= (@vendaId);
end;

------------------------------------------------------------------------------------------------------------------------------
create or alter procedure proc_CRUD_TipoEstoque
@opcao int,
@TipoEstoqueId int,
@descricao varchar(50)
as
begin
	if		(@opcao = 1)
			insert into TipoEstoque(descricaoEstoque)values(
													   @descricao);
	else if	(@opcao = 2)
			update TipoEstoque	set descricaoEstoque = @descricao
								where tipoEstoqueId  = @TipoEstoqueId;
	else if	(@opcao = 3)
			delete from TipoEstoque 
								where tipoEstoqueId	 = @TipoEstoqueId;
end;

------------------------------------------------------------------------------------------------------------------------------
create or alter procedure proc_CRUD_TiposObjetos
@opcao int,
@TiposObjetosId int,
@descricaoObjeto varchar(50),
@nomeObjeto varchar(50)
as 
begin
	if		(@opcao = 1)
		insert into TiposObjetos(descricaoObjeto, nomeObjeto)values(
												    @descricaoObjeto, 
												    @nomeObjeto);
	else if	(@opcao = 2)
		update TiposObjetos set   descricaoObjeto = @descricaoObjeto,
								  nomeObjeto	  = @nomeObjeto
							where tipoObjetoId    = @TiposObjetosId;
	else if	(@opcao = 3)
		delete from TiposObjetos 
							where tipoObjetoId	  = @TiposObjetosId;
end;
------------------------------------------------------------------------------------------------------------------------------
create or alter procedure proc_CRUD_Vendas_Produtos
@opcao				int,
@vendasProdutosId	int,
@vendaId			int,
@produto			varchar(50),
@quantidade			int
as
begin
	declare @unidadeMedida varchar(50), @produtoid int;
	set		@produtoid		= (select produtoId from produtos where descricaoProduto like @produto);
	set		@unidadeMedida  = (select unidadeMedida from Estoque where produtoFK = @produtoid);
	if		(@opcao = 1)
		insert into Vendas_Produtos(vendaFK, produtoFK, quantidade, unidadeMedida)values(
										@vendaId,
										@produtoId,
										@quantidade,
										@unidadeMedida);
		update Vendas set precoTotal = (dbo.func_calc_precoTotal(@vendaId)) where vendaId = (@vendaId);
	if	(@opcao = 2)
		update Vendas_Produtos  set		vendaFK			  = @vendaId,
										produtoFK		  = @produtoId,
										quantidade		  = @quantidade,
										unidadeMedida	  = @unidadeMedida
								where	vendas_ProdutosId = @vendasProdutosId;
		update Vendas set precoTotal = (dbo.func_calc_precoTotal(@vendaId)) where vendaId = @vendaId;
	if (@opcao = 3)
		delete from Vendas_Produtos where vendas_ProdutosId = @vendasProdutosId and
										  vendaFK			= @vendaId;
end;
													
------------------------------------------------------------------------------------------------------------------------------
-- Quando inserido uma venda já da baixa no estoque
CREATE or alter TRIGGER trgInsert_Vendas_Produtos
ON Vendas_Produtos
FOR INSERT
AS
BEGIN
	declare @quantidadeItens int, @codigoProduto int
	select  @quantidadeItens = quantidade, @codigoProduto = produtoFK from inserted
	update Estoque set quantidade = (quantidade - @quantidadeItens)
	where produtoFK = @codigoProduto
END;

------------------------------------------------------------------------------------------------------------------------------
-- Caso seja feito update no banco verifica se a quantidade anterior era maior ou menor que a nova inserida e atualiza o estoque
-- Pensado em situações onde a quantidade inserida tenha sido erronêa
create or alter trigger  trgUpdate_Vendas
on Vendas_Produtos
for update
as 
begin
	declare  @quantidadeAnterior int, @quantidadeNova int, @codigoProduto int
	select   @codigoProduto = produtoFK, @quantidadeNova = quantidade from inserted
	select   @quantidadeAnterior = quantidade from deleted where produtoFK = @codigoProduto
	if		(@quantidadeAnterior > @quantidadeNova)
		update Estoque set quantidade = (quantidade + (@quantidadeAnterior - @quantidadeNova)) where produtoFK = @codigoProduto
	else if	(@quantidadeAnterior < @quantidadeNova)
		update Estoque set quantidade = (quantidade - (@quantidadeNova  - @quantidadeAnterior)) where produtoFK = @codigoProduto
end;

------------------------------------------------------------------------------------------------------------------------------
create or alter view RelatorioVendas as
select vendaId, dataCompra,produtos.descricaoProduto, produtos.precoUnitario, vendas_produtos.quantidade, estoque.unidadeMedida,
(precoUnitario * vendas_produtos.quantidade) as 'Valor total'
from vendas inner join paradas on
vendas.paradaFK = paradas.paradaId inner join vendas_produtos on
vendas.vendaId = vendas_produtos.vendaFk inner join produtos on
vendas_produtos.produtoFK = produtos.produtoId inner join estoque on
produtos.produtoId = estoque.produtoFk

select * from RelatorioVendas
------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------
--insert into Espaconaves(nome, tagName, dataRegistro)		values('Millenium Falcon', 'MFC', '2019-10-18');
--insert into TiposObjetos(descricaoObjeto, nomeObjeto)		values('Planeta', 'Terra');
--insert into TiposObjetos(descricaoObjeto, nomeObjeto)		values('Asteroide', 'Asteroide do Charuto');
--insert into TiposObjetos(descricaoObjeto, nomeObjeto)		values('Planeta', 'Marte');
--insert into TiposObjetos(descricaoObjeto, nomeObjeto)		values('Lua', 'Europa');
--insert into TipoEstoque(descricaoEstoque)					values('Mantimentos');
--insert into TipoEstoque(descricaoEstoque)					values('Combustivel');
--insert into TipoEstoque(descricaoEstoque)					values('Bebidas');
--insert into TipoEstoque(descricaoEstoque)					values('Lazer');
--insert into Produtos(descricaoProduto, precoUnitario)		values('Coca-cola', 5.00);
--insert into Produtos(descricaoProduto, precoUnitario)		values('Combustivel', 10.00 );
--insert into Produtos(descricaoProduto, precoUnitario)		values('Arroz', 7.00 );
--insert into Paradas(nomeParada, tipoObjeto_FK)			values('Parada 01',		
--(select tipoObjetoId from TiposObjetos where nomeObjeto like 'Marte'));
--insert into Paradas(nomeParada, tipoObjeto_FK)			values('Parada Jupiter', 
--(select tipoObjetoId from TiposObjetos where nomeObjeto like 'Europa'));
------------------------------------------------------------------------------------------------------------------------------
--Caso queria testar a basta executar as procs nesta sequência sem ter feito os inserts acima
exec proc_CRUD_Espaconave 1,null,'RocketX','RCX';
select * from Espaconaves

exec proc_CRUD_Produtos 1,null,'Coca-cola', 5.00;
exec proc_CRUD_Produtos 1,null,'Pipoca', 2.00;
exec proc_CRUD_Produtos 1,null,'Querosene', 3.50;
select * from Produtos

exec proc_CRUD_TipoEstoque 1,null, 'Pereciveis';
exec proc_CRUD_TipoEstoque 1,null, 'Combustiveis';
select * from TipoEstoque

exec proc_CRUD_TiposObjetos 1,null,'Sistema Solar','Via lactea';
exec proc_CRUD_TiposObjetos 1,null,'Planeta', 'Terra';
select * from TiposObjetos

exec proc_CRUD_Paradas 1,null,'Via lactea','Parada do Charuto';
exec proc_CRUD_Paradas 1,null,'Terra','ISS' 
select * from Paradas

exec proc_CRUD_Estoque 1, null, 'Parada do Charuto', 'Pereciveis', 'Coca-cola', 500, 'Garrafa 2L';
exec proc_CRUD_Estoque 1, null, 'Parada do charuto', 'Pereciveis', 'Pipoca', 300, 'Saco 300 Gramas'
exec proc_CRUD_Estoque 1,null, 'ISS','Combustiveis','Querosene', 10000, 'Litro'
select * from Estoque

exec proc_CRUD_Vendas 1,null,'Parada do Charuto','RocketX'
exec proc_CRUD_Vendas 1,null,'ISS','RocketX'

exec proc_CRUD_Vendas_Produtos 1,null,1,'Pipoca',20
exec proc_CRUD_Vendas_Produtos 1,null,1,'Coca-cola',10
exec proc_CRUD_Vendas_Produtos 1,null,2,'Querosene', 500

select * from Vendas_Produtos
select * from Estoque
select * from Vendas
select * from produtos
select * from Espaconaves
select * from tipoEstoque
select * from paradas