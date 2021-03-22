
** Dependent variable: V-Dem physical violence index (Coppedge et al. 2017)

** Indepednent vars: aid suspension, trade agreemnts suspension, 
** individual sanctions, embargoes, threats

** Controls: wars, sanctions sent by others, total trade with EU, 
** trade with Russia, total oda, population, GDP

** set the panel data structure
xtset ccode
xtset ccode year
xtset ccode year, yearly

sum  aidsuspension indivsanctions sectoralembargoes porstponmentofratification threat if country !="Russia"
gen sanctint = . if country !="Russia"
replace sanctint = aidsuspension + indivsanctions + sectoralembargoes + porstponmentofratification + threat if country !="Russia"
sum sanctint if sanctint == 0 & country !="Russia"
sum sanctint if sanctint > 0 & country !="Russia"
sum sanctint if sanctint == . & country !="Russia"
sum sanctint if sanctint == .

////////////////////////////////////////////////////////////////////////////////
///////////////////////////  Tests  //////////////////////////////////////////// 
////////////////////////////////////////////////////////////////////////////////

//1. Wooldrige test for autocorrelation/serial correlation
net sj 3-2 st0039
xtserial v2x_clphy
// Prob > F = 0.0000 autocorrelation 

xtabond v2x_clphy LLLv2x_clphy LLextent LLlogpop LLloggdppc LLintrawar LLinterwar ///
LLpolity LLothersanction Lv2x_clphy ll.russia_relative_power_totaltrade, vce(robust)
estat abond
//only first order autocorrelation detected
 
// 2. check for heteroskedasticity
xtreg v2x_clphy LLLv2x_clphy LLextent LLlogpop LLloggdppc LLintrawar LLinterwar ///
LLpolity LLothersanction, fe 
xttest3
//Prob>chi2 =  0.000, heteroskedasticity detect 
 
// 3. Stationarity test (unit root test) using Levin-Lin-Chu test
xtunitroot llc v2x_clphy
//p-value =  0.2832, the data is not stationary, there is unit root
xtunitroot llc d.v2x_clphy
// does not have unit root at level, the data are stationary
// therefore, due to stationarity I(1), I use first order difference

xtunitroot llc  Lextent
xtunitroot llc  d.Lextent

xtunitroot llc logpop
xtunitroot llc d.logpop

xtunitroot llc intrawar
xtunitroot llc d.intrawar

xtunitroot llc rusrelpower_totaltrade_new
xtunitroot llc d.rusrelpower_totaltrade_new

 //4. Heterogeneity test
graph box v2x_clphy, over(country) 
 * b. Wald tests
xtreg v2x_clphy aidsuspension indivsanctions sectoralembargoes ///
porstponmentofratification threat population intrawar interwar,fe
xttest3
//heterogeniety detected

// 5. Heteroskedasticity by using modified Wald test
xtgls v2x_clphy LLLv2x_clphy LLextent LLlogpop LLloggdppc LLintrawar LLinterwar ///
LLpolity LLothersanction , igls panels (heteroskedastic)
//heteroskedasticity detected

// 6. Contemporality (cross-sectional dependence) by using Pesarian's CD test
xtreg v2x_clphy Lv2x_clphy Lextent Llogpop Lloggdppc Lintrawar Linterwar ///
Lpolity Lothersanction 
xtcsd, pesaran abs
//Pr = 0.4274
//cross-sectional dependence is not detected 


********************************************************************************
********************************* model 1 **************************************
********************************************************************************

// rusrelpower_totaltrade_new = export + import
xtreg d.v2x_clphy Lextent Llogpop Lloggdppc Lintrawar Linterwar ///
Lpolity4  Llogeudistance i.year  d.Lv2x_clphy d.LLv2x_clphy  l.odapercapita ///
l.rusrelpower_totaltrade_new Ltreaties if ccode !=  365, vce(robust)
est sto lag1

xtreg d.v2x_clphy LLextent LLlogpop LLloggdppc LLintrawar LLinterwar l.capacitywb ///
LLpolity4 i.year d.Lv2x_clphy d.LLLv2x_clphy  ll.odapercapita ///
ll.rusrelpower_totaltrade_new ll.treaties if ccode !=  365, vce(robust)
testparm i.year

estimates store e1, title (Model 1)
est sto lag2
margins, at (LLextent = (0(1)5))
marginsplot, recast(line) recastci(rarea) yline(0)

xtreg d.v2x_clphy LLextent LLlogpop LLloggdppc LLintrawar LLinterwar l.capacitywb ///
LLpolity4 i.year d.Lv2x_clphy d.LLLv2x_clphy  ll.odapercapita ///
ll.rusrelpower_totaltrade_new ll.treaties if ccode !=  365 & country != "Belarus", vce(robust)
estimates store e1a, title (Model 1a)

//Diff. models since stationarity tests are considered to be not very precise when T is short
// and the tests requires stringly balanced data (not all vars are balanced)
// However, theoretically, all of them can have a time trend. Therefore:

xtreg d.v2x_clphy d.Lextent d.Llogpop d.Lloggdppc d.Lintrawar d.Linterwar ///
d.Lpolity4  d.Llogeudistance i.year  d.Lv2x_clphy d.LLv2x_clphy  d.l.odapercapita ///
d.l.rusrelpower_totaltrade_new d.Ltreaties if ccode !=  365, vce(robust)

xtreg d.v2x_clphy d.LLextent d.LLlogpop d.LLloggdppc d.LLintrawar d.LLinterwar d.l.capacitywb ///
d.LLpolity4 i.year d.Lv2x_clphy d.LLLv2x_clphy  d.ll.odapercapita ///
d.ll.rusrelpower_totaltrade_new d.ll.treaties if ccode !=  365, vce(robust)

//Similar results t-3
xtreg d.v2x_clphy d.LLLextent d.LLLlogpop d.LLLloggdppc d.LLLintrawar d.LLLinterwar ///
d.LLLpolity4  d.LLLlogeudistance i.year  d.Lv2x_clphy d.LLLLv2x_clphy d.lll.odapercapita ///
d.lll.rusrelpower_totaltrade_new d.lll.treaties if ccode !=  365, vce(robust)
////////////////////////////////////////////////////////////////////////////////

// Prepare Figure 1
xtreg d.v2x_clphy LLLextent LLLlogpop LLLloggdppc LLLintrawar LLLinterwar ///
LLLpolity4  LLLlogeudistance i.year  d.Lv2x_clphy d.LLLLv2x_clphy lll.odapercapita ///
lll.rusrelpower_totaltrade_new if ccode !=  365, vce(robust)
est sto lag3

xtreg d.v2x_clphy LLLLextent llll.logpop llll.loggdppc llll.intrawar llll.interwar ///
llll.polity4  llll.logeudistance i.year  d.Lv2x_clphy d.LLLLLv2x_clphy llll.odapercapita ///
llll.rusrelpower_totaltrade_new if ccode !=  365, vce(robust)
est sto lag4

// Figure 1
coefplot lag1 lag2 lag3 lag4, keep( Lextent || LLextent || LLLextent || LLLLextent) xline(0)


** ROBUSTNESS CHECK
** relative power = export (more data points)
xtreg d.v2x_clphy Lextent Llogpop Lloggdppc Lintrawar Linterwar ///
Lpolity4  Llogeudistance year  d.Lv2x_clphy d.LLv2x_clphy  l.odapercapita ///
Lrussia_relative_powerexp Ltreaties if ccode !=  365, vce(robust)

xtreg d.v2x_clphy LLextent LLlogpop LLloggdppc LLintrawar LLinterwar ///
LLpolity4  LLlogeudistance year  d.Lv2x_clphy d.LLLv2x_clphy  ll.odapercapita ///
LLrussia_relative_powerexp ll.treaties if ccode !=  365, vce(robust)

xtreg d.v2x_clphy LLLextent LLLlogpop LLLloggdppc LLLintrawar LLLinterwar ///
LLLpolity4  LLLlogeudistance year  d.Lv2x_clphy d.LLLLv2x_clphy lll.odapercapita ///
LLLrussia_relative_powerexp lll.treaties if ccode !=  365, vce(robust)

xtreg d.v2x_clphy LLLLextent llll.logpop llll.loggdppc llll.intrawar llll.interwar ///
llll.polity4  llll.logeudistance year  d.Lv2x_clphy d.llll.v2x_clphy llll.odapercapita ///
LLLLrussia_relative_powerexp llll.treaties if ccode !=  365, vce(robust)

** percent of export to the eu = eu power (percentofexporttotheeu)
xtreg d.v2x_clphy Lextent Llogpop Lloggdppc Lintrawar Linterwar ///
Lpolity4  Llogeudistance year  d.Lv2x_clphy d.LLv2x_clphy l.odapercapita ///
Lpercentofexporttotheeu if ccode !=  365, vce(robust)

xtreg d.v2x_clphy LLextent LLlogpop LLloggdppc LLintrawar LLinterwar ///
LLpolity4  LLlogeudistance year  d.Lv2x_clphy d.LLLv2x_clphy ll.odapercapita ///
LLpercentofexporttotheeu if ccode !=  365, vce(robust)

xtreg d.v2x_clphy LLLextent LLLlogpop LLLloggdppc LLLintrawar LLLinterwar ///
LLLpolity4  LLLlogeudistance year  d.Lv2x_clphy d.LLLLv2x_clphy lll.odapercapita ///
LLLpercentofexporttotheeu if ccode !=  365, vce(robust)

** Additional control variables 
xtreg d.v2x_clphy LLextent LLlogpop LLloggdppc LLintrawar LLinterwar l.capacitywb ///
LLpolity4  LLlogeudistance i.year d.Lv2x_clphy d.LLLv2x_clphy  ll.odapercapita ///
LLrussia_relative_powerexp ll.othersanctions if ccode !=  365, vce(robust)

cor Lextent Laidsus Lind Larms Lagree Lthreat 

//Model 2-6: disaggregated
xtreg d.v2x_clphy Laidsus Lind Larms Lagree Lthreat Llogpop Lloggdppc Lintrawar Linterwar ///
Lpolity4 i.year  d.Lv2x_clphy d.LLv2x_clphy l.odapercapita ///
l.rusrelpower_totaltrade_new l.capacitywb l.treaties if ccode !=  365, vce(robust)
testparm i.year
estimates store e3, title (Model 2)

xtreg d.v2x_clphy Laidsus Lind Larms Lagree Lthreat Llogpop Lloggdppc Lintrawar Linterwar ///
Lpolity4 i.year  d.Lv2x_clphy d.LLv2x_clphy l.odapercapita ///
l.rusrelpower_totaltrade_new l.capacitywb l.treaties if ccode !=  365 & country != "Belarus", vce(robust)
estimates store e3a, title (Model 2a)


xtreg d.v2x_clphy LLaidsus LLind LLarms LLagree LLthreat LLlogpop LLloggdppc LLintrawar LLinterwar ///
LLpolity4 i.year  d.Lv2x_clphy d.LLLv2x_clphy  ll.odapercapita ///
ll.rusrelpower_totaltrade_new ll.capacitywb ll.treaties if ccode !=  365, vce(robust)
 
xtreg d.v2x_clphy LLLaidsus LLLind LLLarms LLLagree LLLthreat LLLlogpop LLLloggdppc LLLintrawar LLLinterwar ///
LLLpolity4 i.year  d.Lv2x_clphy d.LLLLv2x_clphy  lll.odapercapita ///
lll.rusrelpower_totaltrade_new lll.capacitywb lll.treaties if ccode !=  365, vce(robust)

cor LLaidsus LLind LLarms LLagree LLthreat
// individual elements of coercion are highly correlated. TO avoid issues associated with 
// multicollinearity (and type II) error, I include into the model elements 
// of coercion one by one leaving aside the rest of elements.

// Individual sanctions
xtreg d.v2x_clphy Lind Llogpop Lloggdppc Lintrawar Linterwar l.capacitywb ///
Lpolity4 year  d.Lv2x_clphy d.LLv2x_clphy  l.odapercapita l.capacitywb ///
l.rusrelpower_totaltrade_new l.treaties if ccode !=  365, fe vce(robust)

xtreg d.v2x_clphy LLind LLlogpop LLloggdppc LLintrawar LLinterwar ///
LLpolity4 i.year  d.Lv2x_clphy d.LLLv2x_clphy  ll.odapercapita ll.capacitywb  ///
ll.rusrelpower_totaltrade_new ll.treaties if ccode !=  365, vce(robust)
estimates store e5, title (Model 3)

estimates store e1, title (Model 3)
est sto lag2
margins, at (LLind = (0(1)1))
marginsplot, recast(line) recastci(rarea) yline(0)

xtreg d.v2x_clphy LLLind LLLlogpop LLLloggdppc LLLintrawar LLLinterwar ///
LLLpolity4  i.year  d.Lv2x_clphy d.LLLLv2x_clphy  lll.odapercapita ll.capacitywb  ///
lll.rusrelpower_totaltrade_new lll.treaties if ccode !=  365, vce(robust) 

xtreg d.v2x_clphy LLind LLlogpop LLloggdppc LLintrawar LLinterwar ///
LLpolity4 i.year  d.Lv2x_clphy d.LLLv2x_clphy  ll.odapercapita ll.capacitywb  ///
ll.rusrelpower_totaltrade_new ll.treaties if ccode !=  365 & country != "Belarus", vce(robust)
estimates store e5a, title (Model 3a)

// Arms embargo
xtreg d.v2x_clphy Larms Llogpop Lloggdppc Lintrawar Linterwar ///
Lpolity4 i.year  d.Lv2x_clphy d.LLv2x_clphy  l.odapercapita ///
l.rusrelpower_totaltrade_new l.capacitywb l.treaties if ccode !=  365, vce(robust)
estimates store e6, title (Model 4)

estimates store e1, title (Model 4)
est sto lag2
margins, at (Larms = (0(1)1))
marginsplot, recast(line) recastci(rarea) yline(0)

xtreg d.v2x_clphy Larms Llogpop Lloggdppc Lintrawar Linterwar ///
Lpolity4 i.year  d.Lv2x_clphy d.LLv2x_clphy  l.odapercapita ///
l.rusrelpower_totaltrade_new l.capacitywb l.treaties if ccode !=  365 & country != "Belarus", vce(robust)
estimates store e6a, title (Model 4a)

xtreg d.v2x_clphy LLarms LLlogpop LLloggdppc LLintrawar LLinterwar ///
LLpolity4 i.year  d.Lv2x_clphy d.LLLv2x_clphy  ll.odapercapita ///
ll.rusrelpower_totaltrade_new ll.capacitywb ll.treaties if ccode !=  365, vce(robust)

xtreg d.v2x_clphy LLLarms LLLlogpop LLLloggdppc LLLintrawar LLLinterwar ///
LLLpolity4 i.year  d.Lv2x_clphy d.LLLLv2x_clphy  lll.odapercapita ///
lll.rusrelpower_totaltrade_new lll.capacitywb lll.treaties if ccode !=  365, vce(robust)

// Aid suspension
xtreg d.v2x_clphy LLaidsus LLlogpop LLloggdppc LLintrawar LLinterwar ///
LLpolity4 i.year  d.Lv2x_clphy d.LLLv2x_clphy  l.odapercapita l.capacitywb ///
ll.rusrelpower_totaltrade_new ll.capacitywb ll.treaties if ccode !=  365, vce(robust)

xtreg d.v2x_clphy LLLaidsus LLLlogpop LLLloggdppc LLLintrawar LLLinterwar ///
LLLpolity4 i.year  d.Lv2x_clphy d.LLLLv2x_clphy lll.capacitywb  ///
lll.rusrelpower_totaltrade_new lll.capacitywb lll.treaties if ccode !=  365, vce(robust)
estimates store e7, title (Model 5)

estimates store e1, title (Model 5)
est sto lag2
margins, at (LLLaidsus = (0(1)1))
marginsplot, recast(line) recastci(rarea) yline(0)

xtreg d.v2x_clphy LLLaidsus LLLlogpop LLLloggdppc LLLintrawar LLLinterwar ///
LLLpolity4 i.year  d.Lv2x_clphy d.LLLLv2x_clphy lll.capacitywb  ///
lll.rusrelpower_totaltrade_new lll.capacitywb lll.treaties if ccode !=  365 & country != "Belarus", vce(robust)
estimates store e7a, title (Model 5a)

// Agreement postponment
xtreg d.v2x_clphy Lagree Llogpop Lloggdppc Lintrawar Linterwar ///
Lpolity4 i.year  d.Lv2x_clphy d.LLv2x_clphy  l.odapercapita l.capacitywb ///
l.rusrelpower_totaltrade_new l.treaties if ccode !=  365, vce(robust)
estimates store e8, title (Model 6)

estimates store e1, title (Model 6)
est sto lag2
margins, at (Lagree = (0(1)1))
marginsplot, recast(line) recastci(rarea) yline(0)

xtreg d.v2x_clphy LLagree LLlogpop LLloggdppc LLintrawar LLinterwar ///
LLpolity4 i.year  d.Lv2x_clphy d.LLLv2x_clphy  ll.odapercapita ll.capacitywb ///
ll.rusrelpower_totaltrade_new ll.treaties if ccode !=  365, vce(robust)

xtreg d.v2x_clphy LLLagree LLLlogpop LLLloggdppc LLLintrawar LLLinterwar ///
LLLpolity4 i.year  d.Lv2x_clphy d.LLLLv2x_clphy  lll.odapercapita ll.capacitywb ///
lll.rusrelpower_totaltrade_new lll.treaties if ccode !=  365, vce(robust)

xtreg d.v2x_clphy Lagree Llogpop Lloggdppc Lintrawar Linterwar ///
Lpolity4 i.year  d.Lv2x_clphy d.LLv2x_clphy  l.odapercapita l.capacitywb ///
l.rusrelpower_totaltrade_new l.treaties if ccode !=  365 & country != "Belarus", vce(robust)
estimates store e8a, title (Model 6a)

// Threat
xtreg d.v2x_clphy Lthreat Llogpop Lloggdppc Lintrawar Linterwar ///
Lpolity4 i.year  d.Lv2x_clphy d.LLv2x_clphy  l.odapercapita ll.capacitywb ///
l.rusrelpower_totaltrade_new l.treaties if ccode !=  365, vce(robust)
estimates store e9, title (Model 7)

estimates store e1, title (Model 7)
est sto lag2
margins, at (Lthreat = (0(1)1))
marginsplot, recast(line) recastci(rarea) yline(0)

xtreg d.v2x_clphy LLthreat LLlogpop LLloggdppc LLintrawar LLinterwar ///
LLpolity4 i.year  d.Lv2x_clphy d.LLLv2x_clphy  ll.odapercapita ll.capacitywb ///
ll.rusrelpower_totaltrade_new ll.treaties if ccode !=  365, vce(robust)

xtreg d.v2x_clphy LLLthreat LLLlogpop LLLloggdppc LLLintrawar LLLinterwar ///
LLLpolity4 i.year  d.Lv2x_clphy d.LLLLv2x_clphy  lll.odapercapita lll.capacitywb ///
lll.rusrelpower_totaltrade_new lll.treaties if ccode !=  365, vce(robust)


xtreg d.v2x_clphy Lthreat Llogpop Lloggdppc Lintrawar Linterwar ///
Lpolity4 i.year  d.Lv2x_clphy d.LLv2x_clphy  l.odapercapita ll.capacitywb ///
l.rusrelpower_totaltrade_new l.treaties if ccode !=  365 & country != "Belarus", vce(robust)
estimates store e9a, title (Model 7a)

//Table 1
esttab e1 e3 e5 e6 e7 e8 e9 using ///
"C:/Users/ezshyka/Desktop/Table1.rtf", ///
cells(b(star fmt(3)) se(par fmt(2))) ///
legend label title(Table 1.) ///
nonumbers mtitles("Model 1." "Model 2." "Model 3." "Model 4." "Model 5." "Model 6." "Model 7." ) ///
star(* 0.10 ** 0.05 *** 0.01) r2(3) ar2(3) scalars(F bic aic) nogaps replace

//Table 1 without Belarus
esttab e1a e3a e5a e6a e7a e8a e9a using ///
"C:/Users/ezshyka/Desktop/Table1a.rtf", ///
cells(b(star fmt(3)) se(par fmt(2))) ///
legend label title(Table 1.) ///
nonumbers mtitles("Model 1." "Model 2." "Model 3." "Model 4." "Model 5." "Model 6." "Model 7." ) ///
star(* 0.10 ** 0.05 *** 0.01) r2(3) ar2(3) scalars(F bic aic) nogaps replace

********************************************************************************
***************************  Hypothesis 2 **************************************
********************************************************************************

xtreg d.v2x_clphy LextentXLrussia_rel_pownew Lextent Llogpop Lloggdppc Lintrawar Linterwar ///
Lpolity4 i.year  d.Lv2x_clphy d.LLv2x_clphy l.treaties l.capacitywb ///
l.rusrelpower_totaltrade_new l.odapercapita if ccode !=  365, vce(robust)
estimates store e2, title (Model 2)

xtreg d.v2x_clphy LLextentXLLrussia_rel_pownew LLextent LLlogpop LLloggdppc LLintrawar LLinterwar ///
LLpolity4  i.year  d.Lv2x_clphy d.LLLv2x_clphy ll.treaties ll.capacitywb ///
ll.rusrelpower_totaltrade_new ll.odapercapita if ccode !=  365, vce(robust)

** Margins plot (Figure 2)
xtreg d.v2x_clphy Lextent##c.Lrusrelpower_totaltrade_new Llogpop Lloggdppc Lintrawar Linterwar ///
Lpolity4 i.year  d.Lv2x_clphy d.LLv2x_clphy l.treaties l.capacitywb ///
l.odapercapita if ccode !=  365, vce(robust)
margins Lextent, dydx(Lrusrelpower_totaltrade_new)
**confidence intervals
marginsplot, yline(0)
**confidence area
marginsplot, recast(line) recastci(rarea) yline(0)

**to get many lines
quietly margins Lextent, at(Lrusrelpower_totaltrade_new=(-40(25)60))
marginsplot, recast(line) noci addplot(scatter d.v2x_clphy Lrusrelpower_totaltrade_new, jitter(3) msym(oh)) 

**to get individual lines
margins, at(Lextent=(0 1 2 3 4 5) Lrusrelpower_totaltrade_new=(-50(25)50)) vsquish 
marginsplot, recast(line) recastci(rarea) 

**test on significance of interaction
testparm Lextent##c.Lrusrelpower_totaltrade_new
** the overalll interaction is statistically significant.

xtreg d.v2x_clphy LLextentXLLrussia_rel_pownew LLextent LLlogpop LLloggdppc LLintrawar LLinterwar ///
LLpolity4  i.year  d.Lv2x_clphy d.LLLv2x_clphy ll.treaties ll.capacitywb ///
ll.rusrelpower_totaltrade_new ll.odapercapita if ccode !=  365, vce(robust)

**check (alternative operationalization of "altenative")
xtreg d.v2x_clphy LextentXLrussia_rel_powtt Lextent Llogpop Lloggdppc Lintrawar Linterwar ///
Lpolity4 i.year  d.Lv2x_clphy d.LLv2x_clphy l.treaties ll.capacitywb ///
Lrussia_relative_powertt l.odapercapita if ccode !=  365, vce(robust)

xtreg d.v2x_clphy LLextentXLLrussia_rel_powtt LLextent LLlogpop LLloggdppc LLintrawar LLinterwar ///
LLpolity4 i.year  d.Lv2x_clphy d.LLLv2x_clphy ll.treaties ll.capacitywb ///
LLrussia_relative_powertt ll.odapercapita if ccode !=  365, vce(robust)

xtreg d.v2x_clphy LLLextentXLLLrussia_rel_powtt LLLextent LLLlogpop LLLloggdppc LLLintrawar LLLinterwar ///
LLLpolity4  i.year  d.Lv2x_clphy d.LLLLv2x_clphy lll.treaties ///
LLLrussia_relative_powertt lll.odapercapita if ccode !=  365, vce(robust)

xtreg d.v2x_clphy LextentXLrussia_rel_powtt Lextent Llogpop Lloggdppc Lintrawar Linterwar ///
Lpolity4 year  d.Lv2x_clphy d.LLv2x_clphy l.treaties ///
Lrussia_relative_powertt l.odapercapita if ccode !=  365, fe vce(robust)

**check (alternative operationalization of "altenative")
xtreg d.v2x_clphy LextentXLrusrelpowerexp Lextent Lrussia_relative_powerexp ///
Llogpop Lloggdppc Lintrawar Linterwar l.capacitywb  ///
Lpolity4  i.year  d.Lv2x_clphy d.LLv2x_clphy l.treaties ///
l.odapercapita if ccode !=  365, vce(robust)
 
xtreg d.v2x_clphy LLextentXLLrusrelpowerexp LLextent LLrussia_relative_powerexp ///
LLlogpop LLloggdppc LLintrawar LLinterwar ll.capacitywb  ///
LLpolity4 i.year  d.Lv2x_clphy d.LLLv2x_clphy ll.treaties ///
ll.odapercapita if ccode !=  365, fe vce(robust)


////////////////////////////////////////////////////////////////////////////////
/////////////////////Individual elements of sanctions///////////////////////////
////////////////////////////////////////////////////////////////////////////////

// Arms embargo
xtreg d.v2x_clphy LarmsXrusrelativepower Larms Llogpop Lloggdppc Lintrawar Linterwar ///
Lpolity4 i.year  d.Lv2x_clphy d.LLv2x_clphy l.treaties l.capacitywb ///
l.rusrelpower_totaltrade_new l.odapercapita if ccode !=  365, vce(robust)
estimates store e10, title (Model 10)

//Margins plot
xtreg d.v2x_clphy Larms##c.Lrusrelpower_totaltrade_new Llogpop Lloggdppc Lintrawar Linterwar ///
Lpolity4 i.year  d.Lv2x_clphy d.LLv2x_clphy l.treaties l.capacitywb ///
l.odapercapita if ccode !=  365, vce(robust)
margins Larms, dydx(Lrusrelpower_totaltrade_new)
**confidence intervals
marginsplot, yline(0)
**confidence area
marginsplot, recast(line) recastci(rarea) yline(0)


xtreg d.v2x_clphy Larms##c.Lrusrelpower_totaltrade_new Llogpop Lloggdppc Lintrawar Linterwar ///
Lpolity4 i.year  d.Lv2x_clphy d.LLv2x_clphy l.treaties l.capacitywb ///
l.odapercapita if ccode !=  365, vce(robust)
margins Larms, dydx(Lrusrelpower_totaltrade_new)
**confidence intervals
marginsplot, yline(0)
**confidence area
marginsplot, recast(line) recastci(rarea) yline(0)

**to get many lines
quietly margins Larms, at(Lrusrelpower_totaltrade_new=(-50(25)50))
marginsplot, recast(line) noci addplot(scatter d.v2x_clphy Lrusrelpower_totaltrade_new, jitter(3) msym(oh)) 

**to get individual lines
margins, at(Larms=(0 1) Lrusrelpower_totaltrade_new=(-50(25)50)) vsquish 
marginsplot, recast(line) recastci(rarea) 

**test on significance of interaction
testparm Lextent##c.Lrusrelpower_totaltrade_new
** the overalll interaction is statistically significant.

xtreg d.v2x_clphy LLarmsXrusrelativepower LLarms LLlogpop LLloggdppc LLintrawar LLinterwar ///
LLpolity4  i.year  d.Lv2x_clphy d.LLLv2x_clphy ll.treaties ll.capacitywb ///
ll.rusrelpower_totaltrade_new ll.odapercapita if ccode !=  365, vce(robust)

xtreg d.v2x_clphy LLLarmsXrusrelativepower LLLarms LLLlogpop LLLloggdppc LLLintrawar LLLinterwar ///
LLLpolity4  i.year  d.Lv2x_clphy d.LLLLv2x_clphy lll.treaties lll.capacitywb ///
lll.rusrelpower_totaltrade_new lll.odapercapita if ccode !=  365, vce(robust)

// Individual sanctions
xtreg d.v2x_clphy LindXrusrelativepower Lind Llogpop Lloggdppc Lintrawar Linterwar ///
Lpolity4 i.year  d.Lv2x_clphy d.LLv2x_clphy l.treaties l.capacitywb ///
l.rusrelpower_totaltrade_new l.odapercapita if ccode !=  365, vce(robust)
estimates store e11, title (Model 11)

//Margins plot

xtreg d.v2x_clphy Lind##c.Lrusrelpower_totaltrade_new Llogpop Lloggdppc Lintrawar Linterwar ///
Lpolity4 i.year  d.Lv2x_clphy d.LLv2x_clphy l.treaties l.capacitywb ///
l.odapercapita if ccode !=  365, vce(robust)
margins Lind, dydx(Lrusrelpower_totaltrade_new)
**confidence intervals
marginsplot, yline(0)
**confidence area
marginsplot, recast(line) recastci(rarea) yline(0)

xtreg d.v2x_clphy Lind##c.Lrusrelpower_totaltrade_new Llogpop Lloggdppc Lintrawar Linterwar ///
Lpolity4 i.year  d.Lv2x_clphy d.LLv2x_clphy l.treaties l.capacitywb ///
l.odapercapita if ccode !=  365, vce(robust)
margins Lind, dydx(Lrusrelpower_totaltrade_new)
**confidence intervals
marginsplot, yline(0)
**confidence area
marginsplot, recast(line) recastci(rarea) yline(0)

**to get many lines
quietly margins Lind, at(Lrusrelpower_totaltrade_new=(-40(25)60))
marginsplot, recast(line) noci addplot(scatter d.v2x_clphy Lrusrelpower_totaltrade_new, jitter(3) msym(oh)) 

**to get individual lines
margins, at(Lind=(0 1) Lrusrelpower_totaltrade_new=(-50(25)50)) vsquish 
marginsplot, recast(line) recastci(rarea) 

xtreg d.v2x_clphy LLindXrusrelativepower LLind LLlogpop LLloggdppc LLintrawar LLinterwar ///
LLpolity4  i.year  d.Lv2x_clphy d.LLLv2x_clphy ll.treaties ll.capacitywb ///
ll.rusrelpower_totaltrade_new ll.odapercapita if ccode !=  365, vce(robust)

// Threat of sanctions
xtreg d.v2x_clphy LthreatXalternative Lthreat Llogpop Lloggdppc Lintrawar Linterwar ///
Lpolity4 i.year  d.Lv2x_clphy d.LLv2x_clphy l.treaties l.capacitywb ///
l.rusrelpower_totaltrade_new l.odapercapita if ccode !=  365, vce(robust)
estimates store e12, title (Model 12)

 //Margins plot
 
xtreg d.v2x_clphy Lthreat##c.Lrusrelpower_totaltrade_new Llogpop Lloggdppc Lintrawar Linterwar ///
Lpolity4 i.year  d.Lv2x_clphy d.LLv2x_clphy l.treaties l.capacitywb ///
l.odapercapita if ccode !=  365, vce(robust)
margins Lthreat, dydx(Lrusrelpower_totaltrade_new)
**confidence intervals
marginsplot, yline(0)
**confidence area
marginsplot, recast(line) recastci(rarea) yline(0)


xtreg d.v2x_clphy Lthreat##c.Lrusrelpower_totaltrade_new Llogpop Lloggdppc Lintrawar Linterwar ///
Lpolity4 i.year  d.Lv2x_clphy d.LLv2x_clphy l.treaties l.capacitywb ///
l.odapercapita if ccode !=  365, vce(robust)
margins Lthreat, dydx(Lrusrelpower_totaltrade_new)
**confidence intervals
marginsplot, yline(0)
**confidence area
marginsplot, recast(line) recastci(rarea) yline(0)

**to get individual lines
margins, at(Lthreat=(0 1) Lrusrelpower_totaltrade_new=(-50(25)50)) vsquish 
marginsplot, recast(line) recastci(rarea)

xtreg d.v2x_clphy LLthreatXalternative LLthreat LLlogpop LLloggdppc LLintrawar LLinterwar ///
LLpolity4  i.year  d.Lv2x_clphy d.LLLv2x_clphy ll.treaties ll.capacitywb ///
ll.rusrelpower_totaltrade_new ll.odapercapita if ccode !=  365, vce(robust)

// Postponment of agreemtns
xtreg d.v2x_clphy LagreeXalternative  Lagree Llogpop Lloggdppc Lintrawar Linterwar ///
Lpolity4 i.year  d.Lv2x_clphy d.LLv2x_clphy l.treaties l.capacitywb ///
l.rusrelpower_totaltrade_new l.odapercapita if ccode !=  365, vce(robust)
estimates store e13, title (Model 13)

//Margins plot
xtreg d.v2x_clphy Lagree##c.Lrusrelpower_totaltrade_new Llogpop Lloggdppc Lintrawar Linterwar ///
Lpolity4 i.year  d.Lv2x_clphy d.LLv2x_clphy l.treaties l.capacitywb ///
l.odapercapita if ccode !=  365, vce(robust)
margins Lagree, dydx(Lrusrelpower_totaltrade_new)
**confidence intervals
marginsplot, yline(0)
**confidence area
marginsplot, recast(line) recastci(rarea) yline(0)

xtreg d.v2x_clphy Lagree##c.Lrusrelpower_totaltrade_new Llogpop Lloggdppc Lintrawar Linterwar ///
Lpolity4 i.year  d.Lv2x_clphy d.LLv2x_clphy l.treaties l.capacitywb ///
l.odapercapita if ccode !=  365, vce(robust)
margins Lagree, dydx(Lrusrelpower_totaltrade_new)
**confidence intervals
marginsplot, yline(0)
**confidence area
marginsplot, recast(line) recastci(rarea) yline(0)

**to get individual lines
margins, at(Lagree=(0 1) Lrusrelpower_totaltrade_new=(-50(25)50)) vsquish 
marginsplot, recast(line) recastci(rarea)


xtreg d.v2x_clphy LLagreeXalternative  LLagree LLlogpop LLloggdppc LLintrawar LLinterwar ///
LLpolity4  i.year  d.Lv2x_clphy d.LLLv2x_clphy ll.treaties ll.capacitywb ///
ll.rusrelpower_totaltrade_new ll.odapercapita if ccode !=  365, vce(robust)

xtreg d.v2x_clphy LLLagreeXalternative  LLLagree LLLlogpop LLLloggdppc LLLintrawar LLLinterwar ///
LLLpolity4  i.year  d.Lv2x_clphy d.LLLLv2x_clphy lll.treaties lll.capacitywb ///
lll.rusrelpower_totaltrade_new lll.odapercapita if ccode !=  365, vce(robust)

// Aid suspension
xtreg d.v2x_clphy LaidsusXalternative  Laidsus Llogpop Lloggdppc Lintrawar Linterwar ///
Lpolity4 i.year  d.Lv2x_clphy d.LLv2x_clphy l.treaties l.capacitywb ///
l.rusrelpower_totaltrade_new l.odapercapita if ccode !=  365, vce(robust)
estimates store e14, title (Model 15)

//Margins plot
xtreg d.v2x_clphy Laidsus##c.Lrusrelpower_totaltrade_new Llogpop Lloggdppc Lintrawar Linterwar ///
Lpolity4 i.year  d.Lv2x_clphy d.LLv2x_clphy l.treaties l.capacitywb ///
l.odapercapita if ccode !=  365, vce(robust)
margins Laidsus, dydx(Lrusrelpower_totaltrade_new)
**confidence intervals
marginsplot, yline(0)
**confidence area
marginsplot, recast(line) recastci(rarea) yline(0)


xtreg d.v2x_clphy Laidsus##c.Lrusrelpower_totaltrade_new Llogpop Lloggdppc Lintrawar Linterwar ///
Lpolity4 i.year  d.Lv2x_clphy d.LLv2x_clphy l.treaties l.capacitywb ///
l.odapercapita if ccode !=  365, vce(robust)
margins Laidsus, dydx(Lrusrelpower_totaltrade_new)
**confidence intervals
marginsplot, yline(0)
**confidence area
marginsplot, recast(line) recastci(rarea) yline(0)

**to get individual lines
margins, at(Laidsus=(0 1) Lrusrelpower_totaltrade_new=(-50(25)50)) vsquish 
marginsplot, recast(line) recastci(rarea)


xtreg d.v2x_clphy LLaidsusXalternative  LLaidsus LLlogpop LLloggdppc LLintrawar LLinterwar ///
LLpolity4  i.year  d.Lv2x_clphy d.LLLv2x_clphy ll.treaties ll.capacitywb ///
ll.rusrelpower_totaltrade_new ll.odapercapita if ccode !=  365, vce(robust)

xtreg d.v2x_clphy LLLaidsusXalternative  LLLaidsus LLLlogpop LLLloggdppc LLLintrawar LLLinterwar ///
LLLpolity4  i.year  d.Lv2x_clphy d.LLLLv2x_clphy lll.treaties lll.capacitywb ///
lll.rusrelpower_totaltrade_new lll.odapercapita if ccode !=  365, vce(robust)

// Table 2
esttab e2 e10 e11 e12 e13 e14 using ///
"C:/Desktop/Table_2.rtf", ///
cells(b(star fmt(3)) se(par fmt(2))) ///
legend label title(Table 2. ) ///
nonumbers mtitles("Model 9." "Model 10." "Model 11." "Model 12." "Model 13." "Model 14." "Model 15." ) ///
star(* 0.10 ** 0.05 *** 0.01) r2(3) ar2(3) scalars(F bic aic) nogaps replace

////////////////////////////////////////////////////////////////////////////////
///////////////  Robustness Checks with instruemntal variables  ////////////////
////////////////////////////////////////////////////////////////////////////////

** Arellano-Bond linear dynamic panel-data estimation
xtabond d.v2x_clphy LLextent LLlogpop LLloggdppc LLintrawar LLinterwar LLcapacitywb ///
LLpolity4 year d.Lv2x_clphy d.LLLv2x_clphy  ll.odapercapita ///
LLrusrelpower_totaltrade_new ll.treaties if ccode !=  365, vce(robust)

** Linear dynamic panel-data estimation
xtdpd d.v2x_clphy L(3).v2x_clphy LLextent LLlogpop LLloggdppc LLintrawar LLinterwar LLcapacitywb ///
LLpolity4 ll.odapercapita year ccode ll.othersanction ///
LLrusrelpower_totaltrade_new ll.treaties, dgmmiv(v2x_clphy, lagrange (2 5)) ///
dgmmiv (LLlogpop LLloggdppc LLintrawar LLinterwar LLcapacitywb ///
LLpolity4 year Lv2x_clphy ll.odapercapita ///
LLrusrelpower_totaltrade_new ll.treaties ll.othersanction) liv(LD3.v2x_clphy)

xtdpd d.v2x_clphy L(2).v2x_clphy L(1).aidsuspension L(1).indivsanctions L(1).sectoralembargoes  /// 
L(1).porstponmentofratification L(1).threat logpop  loggdppc intrawar interwar polity4 ///
 othersanction , dgmmiv(v2x_clphy, lagrange (2 5)) ///
div (L(1).aidsuspension L(1).indivsanctions L(1).sectoralembargoes  /// 
L(2).porstponmentofratification L(1).threat logpop  loggdppc intrawar interwar polity4 ///
 othersanction ) liv(LD2.v2x_clphy) vce(robust) noconst
 
xtdpd d.v2x_clphy L(3).v2x_clphy L(2).aidsuspension L(2).indivsanctions L(2).sectoralembargoes  /// 
L(2).porstponmentofratification L(2).threat logpop  loggdppc intrawar interwar polity4 ///
 othersanction , dgmmiv(v2x_clphy, lagrange (2 5)) ///
div (L(2).aidsuspension L(2).indivsanctions L(3).sectoralembargoes  /// 
L(2).porstponmentofratification L(2).threat logpop  loggdppc intrawar interwar polity4 ///
 othersanction ) liv(LD2.v2x_clphy) vce(robust) noconst
 
xtdpd d.v2x_clphy L(4).v2x_clphy L(3).aidsuspension L(3).indivsanctions L(3).sectoralembargoes  /// 
L(3).porstponmentofratification L(3).threat logpop  loggdppc intrawar interwar polity4 ///
 othersanction , dgmmiv(v2x_clphy, lagrange (2 5)) ///
div (L(3).aidsuspension L(3).indivsanctions L(3).sectoralembargoes  /// 
L(3).porstponmentofratification L(3).threat logpop  loggdppc intrawar interwar polity4 ///
 othersanction ) liv(LD2.v2x_clphy) vce(robust) noconst

 
log close 


