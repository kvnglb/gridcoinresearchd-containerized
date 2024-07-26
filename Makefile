BOINC=podman exec gridcoin_boinc

attach_projects:
	-$(BOINC) boinccmd --project_attach https://boinc.bakerlab.org/rosetta/ <priv_key>
	-$(BOINC) boinccmd --project_attach https://escatter11.fullerton.edu/nfs/ <priv_key>
	-$(BOINC) boinccmd --project_attach <another_project_url> <priv_key>

start_crunch:
	$(BOINC) boinccmd --set_run_mode always

stop_crunch:
	$(BOINC) boinccmd --set_gpu_mode never
	$(BOINC) boinccmd --set_run_mode never

cpu_perc:
	$(BOINC) bash -c "echo '<global_preferences><max_ncpus_pct>$(perc)</max_ncpus_pct></global_preferences>' | tee /var/lib/boinc/global_prefs_override.xml"
	$(BOINC) boinccmd --read_global_prefs_override
