	SET QUOTED_IDENTIFIER OFF
	declare @cmd nvarchar(max)
	declare @cmds nvarchar(max)
	declare @cmdt nvarchar(max)
	declare @cmdu nvarchar(max)
	declare @cmdaccy nvarchar(max)
	
	declare @table nvarchar(20)
	declare @tablea nvarchar(20)
	declare @tableas nvarchar(20)
	declare @tableat nvarchar(20)
	declare @tableau nvarchar(20)
	declare @accy nvarchar(20)
	declare @accy2 nvarchar(20)
	
	declare @tmp table(
		tablea nvarchar(20),
		tableas nvarchar(20),
		tableat nvarchar(20),
		tableau nvarchar(20),
		accy nvarchar(20)
	)
	print 'acc:'
	set @table = 'acc'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]_1'
	
	declare cursor_table cursor for
	select tablea,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@tablea)
		begin
			set @cmd = "drop view view_"+@tablea
			execute sp_executesql @cmd
		end
		set @cmd = "create view view_"+@tablea+" as select * from "+@tablea+" where len(ISNULL(acc1,''))=5"
		execute sp_executesql @cmd
		fetch next from cursor_table
		into @tablea,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	--有年度
	print 'bbm+bbs:'
	
	--cng
	set @table = 'cng'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	
	--vcc
	set @table = 'vcc'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,tableat,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,@table+'t')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'t')
	begin
		set @cmdt = "drop view view_"+@table+'t'
		execute sp_executesql @cmdt
	end
	set @cmdt = ''
	
	declare cursor_table cursor for
	select tablea,tableas,tableat,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@tableat,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--t
		set @cmdt = @cmdt + case when LEN(@cmdt)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableat
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
		--accyt
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'t'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'t'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'t'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableat
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'t'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'t'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 	
		fetch next from cursor_table
		into @tablea,@tableas,@tableat,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	if LEN(@cmdt)>0
	begin
		set @cmdt = "create view view_"+@table+'t'+ CHAR(13)+"as" + CHAR(13) + @cmdt
		execute sp_executesql @cmdt
	end
	
	--rc2
	set @table = 'rc2'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	
	--ina
	set @table = 'ina'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	--get
	set @table = 'get'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	
	--cut
	set @table = 'cut'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	
	--vcca
	set @table = 'vcca'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	
	--rc2a
	set @table = 'rc2a'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	
	--ordc
	set @table = 'ordc'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,tableat,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,@table+'t')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'t')
	begin
		set @cmdt = "drop view view_"+@table+'t'
		execute sp_executesql @cmdt
	end
	set @cmdt = ''
	
	declare cursor_table cursor for
	select tablea,tableas,tableat,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@tableat,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--t
		set @cmdt = @cmdt + case when LEN(@cmdt)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableat
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
		--accyt
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'t'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'t'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'t'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableat
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'t'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'t'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 	
		fetch next from cursor_table
		into @tablea,@tableas,@tableat,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	if LEN(@cmdt)>0
	begin
		set @cmdt = "create view view_"+@table+'t'+ CHAR(13)+"as" + CHAR(13) + @cmdt
		execute sp_executesql @cmdt
	end
	--quat
	set @table = 'quat'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	--vcce
	set @table = 'vcce'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	--ucce
	set @table = 'ucce'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
--============================================================================================
print 'bbm+bbs+bbt:'
	--orde
	set @table = 'orde'
	print space(4)+@table+' view_ordeXXX view_ordesXXX 有不一樣'
	delete @tmp
	insert into @tmp(tablea,tableas,tableat,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,@table+'t')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'t')
	begin
		set @cmdt = "drop view view_"+@table+'t'
		execute sp_executesql @cmdt
	end
	set @cmdt = ''
	
	declare cursor_table cursor for
	select tablea,tableas,tableat,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@tableat,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea+"  a outer apply (select count(*) vcce from view_vcces where ordeno=a.noa) b"
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--t
		set @cmdt = @cmdt + case when LEN(@cmdt)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableat
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2+"  a outer apply (select count(*) vcce from view_vcces where ordeno=a.noa) b"
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea+" a outer apply (select count(*) vcce from view_vcces where ordeno=a.noa) b"
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2+" a outer apply (select count(*) vcce from view_vcces where ordeno=a.noa) b"
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,a.*,d.nick cust,'' mechno,'' mech,'' tdmount,d.kind kind,d.memo amemo,d.coin acoin,d.floata afloata"
				+char(13)+space(4)+"from "+@table+"s"+@accy2+" a" 
				+char(13)+space(4)+"left join cust b on a.custno = b.noa" 
				+char(13)+space(4)+"left join "+@table+@accy2+" d on a.noa = d.noa" 
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end 
			+space(4)+"select '"+@accy+"' accy,a.*,d.nick cust,'' mechno,'' mech,'' tdmount,d.kind kind,d.memo amemo,d.coin acoin,d.floata afloata"
			+char(13)+space(4)+"from "+@table+"s"+@accy+" a" 
			+char(13)+space(4)+"left join cust b on a.custno = b.noa" 
			+char(13)+space(4)+"left join "+@table+@accy+" d on a.noa = d.noa" 
		
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)
				+space(4)+"select '"+@accy2+"' accy,a.*,d.nick cust,'' mechno,'' mech,'' tdmount,d.kind kind,d.memo amemo,d.coin acoin,d.floata afloata"
				+char(13)+space(4)+"from "+@table+"s"+@accy2+" a" 
				+char(13)+space(4)+"left join cust b on a.custno = b.noa" 
				+char(13)+space(4)+"left join "+@table+@accy2+" d on a.noa = d.noa" 
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
		--accyt
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'t'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'t'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'t'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableat
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'t'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'t'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 	
		fetch next from cursor_table
		into @tablea,@tableas,@tableat,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	if LEN(@cmdt)>0
	begin
		set @cmdt = "create view view_"+@table+'t'+ CHAR(13)+"as" + CHAR(13) + @cmdt
		execute sp_executesql @cmdt
	end
	
	--cuw
	set @table = 'cuw'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,tableat,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,@table+'t')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'t')
	begin
		set @cmdt = "drop view view_"+@table+'t'
		execute sp_executesql @cmdt
	end
	set @cmdt = ''
	
	declare cursor_table cursor for
	select tablea,tableas,tableat,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@tableat,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--t
		set @cmdt = @cmdt + case when LEN(@cmdt)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableat
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
		--accyt
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'t'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'t'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'t'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableat
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'t'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'t'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 	
		fetch next from cursor_table
		into @tablea,@tableas,@tableat,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	if LEN(@cmdt)>0
	begin
		set @cmdt = "create view view_"+@table+'t'+ CHAR(13)+"as" + CHAR(13) + @cmdt
		execute sp_executesql @cmdt
	end
--============================================================================================
print 'bbm+bbs+bbt+bbu:'
	--cub
	set @table = 'cub'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,tableat,tableau,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,@table+'t')
	,replace(TABLE_NAME,@table,@table+'u')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'t')
	begin
		set @cmdt = "drop view view_"+@table+'t'
		execute sp_executesql @cmdt
	end
	set @cmdt = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'u')
	begin
		set @cmdu = "drop view view_"+@table+'u'
		execute sp_executesql @cmdu
	end
	set @cmdu = ''
	
	declare cursor_table cursor for
	select tablea,tableas,tableat,tableau,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@tableat,@tableau,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--t
		set @cmdt = @cmdt + case when LEN(@cmdt)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableat
		--u
		set @cmdu = @cmdu + case when LEN(@cmdu)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableau
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
		--accyt
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'t'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'t'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'t'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableat
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'t'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'t'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 	
		--accyu
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'u'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'u'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'u'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableau
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'u'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'u'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 	
		fetch next from cursor_table
		into @tablea,@tableas,@tableat,@tableau,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	if LEN(@cmdt)>0
	begin
		set @cmdt = "create view view_"+@table+'t'+ CHAR(13)+"as" + CHAR(13) + @cmdt
		execute sp_executesql @cmdt
	end
	if LEN(@cmdu)>0
	begin
		set @cmdu = "create view view_"+@table+'u'+ CHAR(13)+"as" + CHAR(13) + @cmdu
		execute sp_executesql @cmdu
	end
	
	
--10501------------------------------------------------------------

	--cua
	set @table = 'cua'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	
	--cuc
	set @table = 'cuc'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end	
	
	--cud
	set @table = 'cud'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	
	--cug
	set @table = 'cug'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,tableat,tableau,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,@table+'t')
	,replace(TABLE_NAME,@table,@table+'u')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'t')
	begin
		set @cmdt = "drop view view_"+@table+'t'
		execute sp_executesql @cmdt
	end
	set @cmdt = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'u')
	begin
		set @cmdu = "drop view view_"+@table+'u'
		execute sp_executesql @cmdu
	end
	set @cmdu = ''
	
	declare cursor_table cursor for
	select tablea,tableas,tableat,tableau,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@tableat,@tableau,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--t
		set @cmdt = @cmdt + case when LEN(@cmdt)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableat
		--u
		set @cmdu = @cmdu + case when LEN(@cmdu)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableau
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
		--accyt
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'t'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'t'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'t'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableat
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'t'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'t'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 	
		--accyu
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'u'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'u'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'u'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableau
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'u'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'u'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 	
		fetch next from cursor_table
		into @tablea,@tableas,@tableat,@tableau,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	if LEN(@cmdt)>0
	begin
		set @cmdt = "create view view_"+@table+'t'+ CHAR(13)+"as" + CHAR(13) + @cmdt
		execute sp_executesql @cmdt
	end
	if LEN(@cmdu)>0
	begin
		set @cmdu = "create view view_"+@table+'u'+ CHAR(13)+"as" + CHAR(13) + @cmdu
		execute sp_executesql @cmdu
	end
	
	--cuv
	set @table = 'cuv'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	
	--inb
	set @table = 'inb'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	
	--ordb
	set @table = 'ordb'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,tableat,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,@table+'t')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'t')
	begin
		set @cmdt = "drop view view_"+@table+'t'
		execute sp_executesql @cmdt
	end
	set @cmdt = ''
	
	declare cursor_table cursor for
	select tablea,tableas,tableat,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@tableat,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--t
		set @cmdt = @cmdt + case when LEN(@cmdt)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableat
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
		--accyt
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'t'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'t'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'t'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableat
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'t'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'t'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 	
		fetch next from cursor_table
		into @tablea,@tableas,@tableat,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	if LEN(@cmdt)>0
	begin
		set @cmdt = "create view view_"+@table+'t'+ CHAR(13)+"as" + CHAR(13) + @cmdt
		execute sp_executesql @cmdt
	end
	
	--ordex
	set @table = 'ordex'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end	
	
	--ordg
	set @table = 'ordg'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end	
	
	--rc2b
	set @table = 'rc2b'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end	
	
	--tranorde
	set @table = 'tranorde'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end	
	
	--tranorde
	set @table = 'tranorde'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end	
	
	--transvcce
	set @table = 'transvcce'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end	
	
	--trd
	set @table = 'trd'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end	
	
	--tre
	set @table = 'tre'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end	
	
	--vccd
	set @table = 'vccd'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end	
	
	--trans
	set @table = 'trans'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
		
	declare cursor_table cursor for
	select tablea,tableas,tableat,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@tableat,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
			
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		
		fetch next from cursor_table
		into @tablea,@tableas,@tableat,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	
	--wcost
	set @table = 'wcost'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
		
	declare cursor_table cursor for
	select tablea,tableas,tableat,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@tableat,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
			
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		
		fetch next from cursor_table
		into @tablea,@tableas,@tableat,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	
	
	--work
	set @table = 'work'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	
	--work2
	set @table = 'work2'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,tableat,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,@table+'t')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'t')
	begin
		set @cmdt = "drop view view_"+@table+'t'
		execute sp_executesql @cmdt
	end
	set @cmdt = ''
	
	declare cursor_table cursor for
	select tablea,tableas,tableat,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@tableat,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--t
		set @cmdt = @cmdt + case when LEN(@cmdt)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableat
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
		--accyt
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'t'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'t'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'t'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableat
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'t'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'t'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 	
		fetch next from cursor_table
		into @tablea,@tableas,@tableat,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	if LEN(@cmdt)>0
	begin
		set @cmdt = "create view view_"+@table+'t'+ CHAR(13)+"as" + CHAR(13) + @cmdt
		execute sp_executesql @cmdt
	end
	
	--worka
	set @table = 'worka'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	
	--workb
	set @table = 'workb'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,tableat,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,@table+'t')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'t')
	begin
		set @cmdt = "drop view view_"+@table+'t'
		execute sp_executesql @cmdt
	end
	set @cmdt = ''
	
	declare cursor_table cursor for
	select tablea,tableas,tableat,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@tableat,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--t
		set @cmdt = @cmdt + case when LEN(@cmdt)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableat
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
		--accyt
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'t'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'t'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'t'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableat
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'t'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'t'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 	
		fetch next from cursor_table
		into @tablea,@tableas,@tableat,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	if LEN(@cmdt)>0
	begin
		set @cmdt = "create view view_"+@table+'t'+ CHAR(13)+"as" + CHAR(13) + @cmdt
		execute sp_executesql @cmdt
	end
	
	--workc
	set @table = 'workc'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	
	--workd
	set @table = 'workd'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,tableat,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,@table+'t')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'t')
	begin
		set @cmdt = "drop view view_"+@table+'t'
		execute sp_executesql @cmdt
	end
	set @cmdt = ''
	
	declare cursor_table cursor for
	select tablea,tableas,tableat,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@tableat,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--t
		set @cmdt = @cmdt + case when LEN(@cmdt)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableat
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
		--accyt
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'t'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'t'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'t'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableat
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'t'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'t'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 	
		fetch next from cursor_table
		into @tablea,@tableas,@tableat,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	if LEN(@cmdt)>0
	begin
		set @cmdt = "create view view_"+@table+'t'+ CHAR(13)+"as" + CHAR(13) + @cmdt
		execute sp_executesql @cmdt
	end
	
	--workbq
	set @table = 'workbq'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	
	--workf
	set @table = 'workf'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	
	--workg
	set @table = 'workg'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,tableat,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,@table+'t')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'t')
	begin
		set @cmdt = "drop view view_"+@table+'t'
		execute sp_executesql @cmdt
	end
	set @cmdt = ''
	
	declare cursor_table cursor for
	select tablea,tableas,tableat,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@tableat,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--t
		set @cmdt = @cmdt + case when LEN(@cmdt)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableat
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
		--accyt
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'t'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'t'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'t'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableat
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'t'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'t'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 	
		fetch next from cursor_table
		into @tablea,@tableas,@tableat,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	if LEN(@cmdt)>0
	begin
		set @cmdt = "create view view_"+@table+'t'+ CHAR(13)+"as" + CHAR(13) + @cmdt
		execute sp_executesql @cmdt
	end
	
	--workh
	set @table = 'workh'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	
	--workk
	set @table = 'workk'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	
	--workl
	set @table = 'workl'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	
	--workm
	set @table = 'workm'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	
	
	--workn
	set @table = 'workn'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	
	--worku
	set @table = 'worku'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	
	--workq
	set @table = 'workq'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,tableat,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@tableat,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
		
		fetch next from cursor_table
		into @tablea,@tableas,@tableat,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	
	--workx
	set @table = 'workx'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	
	declare cursor_table cursor for
	select tablea,tableas,tableat,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@tableat,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		
		fetch next from cursor_table
		into @tablea,@tableas,@tableat,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	
	--cugh
	set @table = 'cugh'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	
	declare cursor_table cursor for
	select tablea,tableas,tableat,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@tableat,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		
		fetch next from cursor_table
		into @tablea,@tableas,@tableat,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	
	--accz
	set @table = 'accz'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,tableat,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'a')
	,replace(TABLE_NAME,@table,@table+'t')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]_1'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'a')
	begin
		set @cmds = "drop view view_"+@table+'a'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'t')
	begin
		set @cmdt = "drop view view_"+@table+'t'
		execute sp_executesql @cmdt
	end
	set @cmdt = ''

	declare cursor_table cursor for
	select tablea,tableas,tableat,accy from @tmp order by accy
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@tableat,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+left(@accy,3)+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+left(@accy,3)+"' accy,* from "+@tableas
		--t
		set @cmdt = @cmdt + case when LEN(@cmdt)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+left(@accy,3)+"' accy,* from "+@tableat
		
		fetch next from cursor_table
		into @tablea,@tableas,@tableat,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'a'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	if LEN(@cmdt)>0
	begin
		set @cmdt = "create view view_"+@table+'t'+ CHAR(13)+"as" + CHAR(13) + @cmdt
		execute sp_executesql @cmdt
	end
	
	--costs
	set @table = 'costs'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''

	declare cursor_table cursor for
	select tablea,tableas,tableat,accy from @tmp order by accy
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@tableat,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		
		fetch next from cursor_table
		into @tablea,@tableas,@tableat,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	
	--ordei
	set @table = 'ordei'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''

	declare cursor_table cursor for
	select tablea,tableas,tableat,accy from @tmp order by accy
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@tableat,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		
		fetch next from cursor_table
		into @tablea,@tableas,@tableat,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	
	--ordem
	set @table = 'ordem'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''

	declare cursor_table cursor for
	select tablea,tableas,tableat,accy from @tmp order by accy
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@tableat,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		
		fetch next from cursor_table
		into @tablea,@tableas,@tableat,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	
	--ucch
	set @table = 'ucch'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''

	declare cursor_table cursor for
	select tablea,tableas,tableat,accy from @tmp order by accy
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@tableat,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		
		fetch next from cursor_table
		into @tablea,@tableas,@tableat,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end