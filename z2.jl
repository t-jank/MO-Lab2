#*********************************************
# Szeregowanie na jednej maszynie minimalizujace sume wazonych momentow
# zakonczenia zadan z czasami dostepnosci zadan.
# Danych jest n zadan, 
# czasy pj wykonania j-tego zadania, momenty dostepnosci rj j-tego zadania
# oraz wagi wj j-tego zadania
# j=1,...,n.
# Moment rozpoczecia tj j-tego zadania musi spelniac ograniczenie: tj>=rj.
# 
# Podac harmonogram wykonania wszystkich zadan tak aby 
# suma wazanych momentow zakonczenia zadan byla najmniejsza
#*********************************************

using JuMP
using GLPK
model = Model(GLPK.Optimizer)


function singleMachine(p::Vector{Int}, r::Vector{Int}, w::Vector{Float64}, verbose = true)

 n=length(p)
 #  n - liczba zadan
 #  p - wektor czasow wykonania zadan
 #  r - wektor momentow dostepnosci zadan
 #  w - wektor wag zadan
 # verbose - true, to kominikaty solvera na konsole 		

 T= maximum(r)+sum(p)+1 # dlugosc horyzontu czasowego
 	

 Task = 1:n
 Horizon = 1:T
 
	
	#  zmienne moment rozpoczecia j-tego zadania
	# tjt=1 jesli zadanie rozpoczyna sie w momencie t-1; t in Horizon 
	# 0 w.p.p
	@variable(model, x[Task,Horizon], Bin) 
	
	# minimalizacja sumy wazonych momentow zakonczen zadan
	@objective(model,Min, sum(w[j]*(p[j]+r[j])*x[j,t] for  j in Task, t in Horizon)) 
	
	# dokladnie jeden moment rozpoczenia j-tego zadania
	for j in Task
		@constraint(model,sum(x[j,t] for  t in 1:T-p[j]+1)==1)
	end
	
	# moment rozpoczecia j-tego zadan co najmniej jak moment gotowosci rj zadania
	for j in Task
		@constraint(model,sum((t-1)*x[j,t] for  t in 1:T-p[j]+1)>=r[j])
	end
	# zadania nie nakladaja sie na siebie
	for t in Horizon
		@constraint(model,sum(x[j,s]  for  j in Task, s in max(1, t-p[j]+1):t)<=1)
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

	status=termination_status(model)

	if status== MOI.OPTIMAL
		 return status, objective_value(model), value.(x)
	 else
		 return status, nothing,nothing
	 end
	

		
end # singleMachine

# czasy wykonia j-tego zadania 
p=[3; 2; 4; 5; 1]
# momenty dostepnosci j-tego zadania
r=[2; 1; 3; 1; 0]	
# wagi j-tego zadania		
w=[1.0; 1.0; 1.0; 1.0; 1.0]							 


(status, fcelu, momenty)=singleMachine(p,r,w)

if status== MOI.OPTIMAL
	 println("funkcja celu: ", fcelu)
   println("momenty rozpoczecia zadan: ", momenty)
else
   println("Status: ", status)
end
