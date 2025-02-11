import { forwardRef } from 'react';
import type { HTMLAttributes, ForwardedRef } from 'react';
import { t } from '@18f/identity-i18n';
import { TextInput } from '@18f/identity-components';
import { useInstanceId } from '@18f/identity-react-hooks';
import type { TextInputProps } from '@18f/identity-components';
import './password-toggle-element';
import type PasswordToggleElement from './password-toggle-element';

declare global {
  namespace JSX {
    interface IntrinsicElements {
      'lg-password-toggle': HTMLAttributes<PasswordToggleElement> & { class: string };
    }
  }
}

type TogglePosition = 'top' | 'bottom';

type PasswordToggleProps = Partial<TextInputProps> & {
  /**
   * Input label text.
   */
  label?: string;

  /**
   * Toggle label text.
   */
  toggleLabel?: string;

  /**
   * Placement of toggle relative to the input.
   */
  togglePosition?: TogglePosition;
};

function PasswordToggle(
  {
    label = t('components.password_toggle.label'),
    toggleLabel = t('components.password_toggle.toggle_label'),
    togglePosition = 'top',
    ...textInputProps
  }: PasswordToggleProps,
  ref: ForwardedRef<HTMLInputElement>,
) {
  const instanceId = useInstanceId();
  const inputId = `password-toggle-input-${instanceId}`;
  const toggleId = `password-toggle-${instanceId}`;

  const classes =
    togglePosition === 'top' ? 'password-toggle--toggle-top' : 'password-toggle--toggle-bottom';

  return (
    <lg-password-toggle class={classes}>
      <TextInput
        ref={ref}
        {...textInputProps}
        label={label}
        id={inputId}
        className="password-toggle__input"
      />
      <div className="password-toggle__toggle-wrapper">
        <input
          id={toggleId}
          type="checkbox"
          className="usa-checkbox__input usa-checkbox__input--bordered password-toggle__toggle"
          aria-controls={inputId}
        />
        <label htmlFor={toggleId} className="usa-checkbox__label password-toggle__toggle-label">
          {toggleLabel}
        </label>
      </div>
    </lg-password-toggle>
  );
}

export default forwardRef(PasswordToggle);
