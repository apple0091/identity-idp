import { useEffect } from 'react';
import { FormSteps } from '@18f/identity-form-steps';
import { StepIndicator, StepIndicatorStep, StepStatus } from '@18f/identity-step-indicator';
import { t } from '@18f/identity-i18n';
import { Alert } from '@18f/identity-components';
import { trackEvent } from '@18f/identity-analytics';
import { STEPS } from './steps';

export interface VerifyFlowValues {
  personalKey?: string;

  personalKeyConfirm?: string;

  firstName?: string;

  lastName?: string;

  address1?: string;

  address2?: string;

  city?: string;

  state?: string;

  phone?: string;
}

interface VerifyFlowProps {
  /**
   * Initial values for the form, if applicable.
   */
  initialValues?: Partial<VerifyFlowValues>;

  /**
   * Names of steps to be included in the flow.
   */
  enabledStepNames?: string[];

  /**
   * The path to which the current step is appended to create the current step URL.
   */
  basePath?: string;

  /**
   * Application name, used in generating page titles for current step.
   */
  appName: string;

  /**
   * Callback invoked after completing the form.
   */
  onComplete: () => void;
}

export function VerifyFlow({ initialValues = {}, basePath, appName, onComplete }: VerifyFlowProps) {
  function trackVisitedStepEvent(stepName) {
    if (stepName === 'personal_key') {
      trackEvent('IdV: personal key visited');
    }
    if (stepName === 'personal_key_confirm') {
      trackEvent('IdV: show personal key modal');
    }
  }

  useEffect(() => {
    trackVisitedStepEvent(STEPS[0].name);
  }, []);

  return (
    <>
      <StepIndicator className="margin-x-neg-2 margin-top-neg-4 tablet:margin-x-neg-6 tablet:margin-top-neg-4">
        <StepIndicatorStep title="Getting Started" status={StepStatus.COMPLETE} />
        <StepIndicatorStep title="Verify your ID" status={StepStatus.COMPLETE} />
        <StepIndicatorStep title="Verify your personal details" status={StepStatus.COMPLETE} />
        <StepIndicatorStep title="Verify phone or address" status={StepStatus.COMPLETE} />
        <StepIndicatorStep title="Secure your account" status={StepStatus.CURRENT} />
      </StepIndicator>
      <Alert type="success" className="margin-bottom-4">
        {t('idv.messages.confirm')}
      </Alert>
      <FormSteps
        steps={steps}
        initialValues={initialValues}
        promptOnNavigate={false}
        basePath={basePath}
        titleFormat={`%{step} - ${appName}`}
        onStepSubmit={(submittedStepName) => {
          if (submittedStepName === 'personal_key_confirm') {
            trackEvent('IdV: personal key submitted');
          }
        }}
        onStepChange={(stepName) => {
          trackVisitedStepEvent(stepName);
        }}
        onComplete={onComplete}
      />
    </>
  );
}
