server:
	sh -c "python manage.py runserver"

app:
	sh -c "django-admin startapp apps/$(filter-out $@,$(MAKECMDGOALS))" 

# app.test:
# 	sh -c "MIX_ENV=test mix test $(filter-out $@,$(MAKECMDGOALS)) && \
# 	mix format "

# app.test.watch:
# 	sh -c "MIX_ENV=test mix test.watch $(filter-out $@,$(MAKECMDGOALS))"

# app.credo:
# 	sh -c "mix credo --strict"

%:
	@:
