from wtforms import Form, StringField, BooleanField, IntegerField, DateField, TimeField, SelectField
from wtforms.validators import DataRequired, Email, Length, NumberRange, Optional
from wtforms.widgets import TextInput


class CustomDateField(DateField):
    widget = TextInput()


class CustomTimeField(TimeField):
    widget = TextInput()


class ReservationSearchForm(Form):
    date = CustomDateField("Date", validators=[DataRequired()])
    people = IntegerField("People", validators=[DataRequired(), NumberRange(min=1, max=12)])
    time = CustomTimeField("Time", validators=[DataRequired()])


class ReservationDetailsForm(Form):
    firstName = StringField("First Name", validators=[DataRequired(), Length(min=1, max=50)])
    lastName = StringField("Last Name", validators=[DataRequired(), Length(min=1, max=50)])
    email = StringField("Email", validators=[DataRequired(), Email()])
    phone = StringField("Phone", validators=[Optional(), Length(max=30)])
    occasion = StringField("Occasion", validators=[Optional(), Length(max=255)])
    newsletter = BooleanField("Newsletter", default=False)
    textUpdates = BooleanField("Text Updates", default=False)


class CreateReservationForm(Form):
    date = CustomDateField("Date", validators=[DataRequired()])
    people = IntegerField("People", validators=[DataRequired(), NumberRange(min=1, max=12)])
    time = CustomTimeField("Time", validators=[DataRequired()])

    firstName = StringField("First Name", validators=[DataRequired(), Length(min=1, max=50)])
    lastName = StringField("Last Name", validators=[DataRequired(), Length(min=1, max=50)])
    email = StringField("Email", validators=[DataRequired(), Email()])
    phone = StringField("Phone", validators=[Optional(), Length(max=30)])
    occasion = StringField("Occasion", validators=[Optional(), Length(max=255)])
    newsletter = BooleanField("Newsletter", default=False)
    textUpdates = BooleanField("Text Updates", default=False)

    table_number = IntegerField("Table Number", validators=[Optional(), NumberRange(min=1)])
    status = SelectField(
        "Status",
        choices=[
            ("confirmed", "Confirmed"),
            ("checked_in", "Checked In"),
            ("completed", "Completed"),
            ("cancelled", "Cancelled"),
            ("no_show", "No Show"),
        ],
        default="confirmed",
    )
