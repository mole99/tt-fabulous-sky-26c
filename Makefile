PDK ?= sky130A

TOP ?= tt_um_fabulous_sky_26c

# Get the fabric names
FABRICS :=  $(patsubst fabrics/%,%,$(wildcard fabrics/*)) 

FABRICS_OPENROAD := $(addsuffix -openroad,$(FABRICS))
FABRICS_KLAYOUT := $(addsuffix -klayout,$(FABRICS))
FABRICS_COPY := $(addsuffix -copy,$(FABRICS))

all: $(FABRICS)
.PHONY: all

$(FABRICS):
	librelane --pdk ${PDK} fabrics/$@/config.yaml --save-views-to fabrics/$@/macro/${PDK}/
.PHONY: $(FABRICS)

$(FABRICS_OPENROAD):
	librelane --pdk ${PDK} fabrics/$(subst -openroad,,$@)/config.yaml --last-run --flow OpenInOpenROAD
.PHONY: $(FABRICS_OPENROAD)

$(FABRICS_KLAYOUT):
	librelane --pdk ${PDK} fabrics/$(subst -klayout,,$@)/config.yaml --last-run --flow OpenInKLayout
.PHONY: $(FABRICS_KLAYOUT)

$(FABRICS_COPY):
	# Copy fabric database
	mkdir -p user_designs/fabrics/$(subst -copy,,$@)/macro/${PDK}/
	cp -R fabrics/$(subst -copy,,$@)/macro/${PDK}/fabulous/ user_designs/fabrics/$(subst -copy,,$@)/macro/${PDK}/
	cp fabrics/$(subst -copy,,$@)/constraints.pcf user_designs/fabrics/$(subst -copy,,$@)/constraints.pcf
.PHONY: $(FABRICS_COPY)

tt-fabulous:
	librelane config.yaml --pdk ${PDK} --save-views-to macro/
.PHONY: tt-fabulous

tt-fabulous-openroad:
	librelane config.yaml --pdk ${PDK} --last-run --flow OpenInOpenROAD
.PHONY: tt-fabulous

tt-fabulous-klayout:
	librelane config.yaml --pdk ${PDK} --last-run --flow OpenInKLayout
.PHONY: tt-fabulous

# Copy the files for Tiny Tapeout
tt-fabulous-copy:
	# Copy GDS and LEF
	cp macro/gds/${TOP}.gds gds/${TOP}.gds
	cp macro/lef/${TOP}.lef lef/${TOP}.lef
.PHONY: tt-fabulous-copy

sim-fabric:
	cd tb; PDK=${PDK} SCL=${SCL} python3 fabric_tb.py
.PHONY: sim-fabric

sim-fabric-gl:
	cd tb; GL=1 PDK=${PDK} SCL=${SCL} python3 fabric_tb.py
.PHONY: sim-fabric-gl

sim-top:
	cd tb; PDK=${PDK} SCL=${SCL} python3 top_tb.py
.PHONY: sim-top

sim-top-gl:
	cd tb; GL=1 PDK=${PDK} SCL=${SCL} python3 top_tb.py
.PHONY: sim-top-gl
