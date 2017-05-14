ERRS=$(luacheck src/*.lua src/*/*.lua --no-max-line-length -i ngx -i _M -i _)

echo "$ERRS" | grep "   src" | tail -n 1

F=$(echo "$ERRS" | grep "   src" | sed 's/ //g' | awk '{split($0,a,":"); print "vim +"a[2],a[1]}' | tail -n 1)

echo $F > .f

