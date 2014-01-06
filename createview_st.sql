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
	
	--有年度
	print 'bbm+bbs:'
	--workd
	set @table = 'workd'
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
	print space(4)+@table+'  view_ordesXXX 有不一樣'
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