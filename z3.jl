#*********************************************
# Szeregowanie na maszynach minimalizujace calkowity czas potrzebny na
# zakonczenie wszystkich zadan z relacjami poprzedzania zadan.
# Danych jest n zadan, m maszyn,
# czasy pj wykonania j-tego zadania oraz relacje poprzedzania.
# j=1,...,n.
# Moment rozpoczecia tj j-tego zadania z relacja i->j musi spelniac ograniczenie: tj>=ti+pi.
# 
# Podac harmonogram wykonania wszystkich zadan tak aby 
# czas zakonczenia wszystkich zadan byl minimalny.
#*********************************************

using JuMP
using GLPK
model = Model(GLPK.Optimizer)


function multiMachine(p::Vector{Int}, r::Vector{Vector{Int}}, m, verbose = true)

 n=length(p)
 #  n - liczba zadan
 #  p - wektor czasow wykonania zadan
 #  r - wektor relacji poprzedzania
 #  m - liczba maszyn
 # verbose - true, to kominikaty solvera na konsole 		

 T= sum(p)+1 # dlugosc horyzontu czasowego
 	

 Task = 1:n
 Horizon = 1:T
 Machine = 1:m
 
	@variable(model, aux)
	#  zmienne moment rozpoczecia j-tego zadania
	# jtm=1 jesli zadanie rozpoczyna sie w momencie t-1 na maszynie m;
	# 0 w.p.p
	@variable(model, x[Task,Horizon,Machine], Bin) 
	
	# minimalizacja czasu zakonczenia wszystkich zadan
	@objective(model,Min, aux)
	#@objective(model,Min, max(p[j]*x[j,t,m] for j in Task, t in Horizon, m in Machine)) 
	
	# dokladnie jeden moment rozpoczenia j-tego zadania
	for j in Task
		@constraint(model,sum(x[j,t,m] for  t in 1:T-p[j]+1, m in Machine)==1)
	end

	# relacje poprzedzania i->j moment rozpoczecia j-tego zadania co najmniej jak moment zakonczenia zadania i
	for precedence in r
       		@constraint(model,sum((t-1)*x[precedence[2],t,m] for  t in 1:T-p[precedence[2]]+1, m in Machine)>=sum((t-1+p[precedence[1]] )*x[precedence[1],t,m] for  t in 1:T-p[precedence[1]]+1, m in Machine))
    	end

	# zadania nie nakladaja sie na siebie
	for m in Machine
	    for t in Horizon
	        @constraint(model,sum(x[j,s,m]  for  j in Task, s in max(1, t-p[j]+1):t)<=1)
	    end
	end

    	# calkowity czas zakonczenia >= czasowi zakonczenia dowolnego zadania
    	for m in Machine
            for t in Horizon
                for j in Task
                    @constraint(model, aux >= (t-1+p[j])*x[j,t,m])
            	end
            end
        end
	
	print(model) # drukuj model
    # rozwiaz egzemplarz
	if verbose
		optimize!(model)		
	else
		set_silent(model)
		optimize!(model)
		unset_silent(model)
	end

    for m in Machine
        print("\n")
        to_print = '-'
        how_many_left = 0
        for t in Horizon
            for i in Task
                if value(x[i,t,m])>0
                    to_print = i
                    how_many_left=p[i]
                end
            end
	    print(to_print)
	    how_many_left-=1
            if how_many_left<=0
                to_print = '-'
            end
        end
    end


	status=termination_status(model)

	if status== MOI.OPTIMAL
		 return status, objective_value(model), value.(x)
	 else
		 return status, nothing,nothing
	 end
	
	
end # multiMachine

# czasy wykonia j-tego zadania 
p=[1; 2; 1; 2; 1; 1; 3; 6; 2]
# relacje poprzedzania
r=[[1;4],[2;4],[3;4],[2;5],[3;5],[4;6],[4;7],[5;7],[5;8],[6;9],[7;9]]
# liczba maszyn
m=3

(status, fcelu, momenty)=multiMachine(p,r,m)

if status== MOI.OPTIMAL
	 println("funkcja celu: ", fcelu)
   println("momenty rozpoczecia zadan: ", momenty)
else
   println("Status: ", status)
end
