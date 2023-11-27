server:
	sh -c "python manage.py runserver 0.0.0.0:8000"

app:
	sh -c "django-admin startapp $(filter-out $@,$(MAKECMDGOALS))" 
	touch $(filter-out $@,$(MAKECMDGOALS))/models.py
	mkdir $(filter-out $@,$(MAKECMDGOALS))/api
	touch $(filter-out $@,$(MAKECMDGOALS))/api/__init__.py
	touch $(filter-out $@,$(MAKECMDGOALS))/api/viewsets.py
	touch $(filter-out $@,$(MAKECMDGOALS))/api/serializers.py

	mv $(filter-out $@,$(MAKECMDGOALS)) apps

migrations:
	sh -c "python manage.py makemigrations"

migrate: 
	sh -c "python manage.py migrate"

# app.test:
# 	sh -c "MIX_ENV=test mix test $(filter-out $@,$(MAKECMDGOALS)) && \
# 	mix format "

# app.test.watch:
# 	sh -c "MIX_ENV=test mix test.watch $(filter-out $@,$(MAKECMDGOALS))"

# app.credo:
# 	sh -c "mix credo --strict"

%:
	@:
